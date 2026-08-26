import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum AppLocationPermission { denied, deniedForever, whileInUse, always }

enum UserLocationStatus {
  success,
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class UserCoordinates {
  const UserCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class UserLocationResult {
  const UserLocationResult._({
    required this.status,
    this.coordinates,
    this.usedLastKnownPosition = false,
  });

  const UserLocationResult.success(
    UserCoordinates coordinates, {
    bool usedLastKnownPosition = false,
  }) : this._(
         status: UserLocationStatus.success,
         coordinates: coordinates,
         usedLastKnownPosition: usedLastKnownPosition,
       );

  const UserLocationResult.failure(UserLocationStatus status)
    : this._(status: status);

  final UserLocationStatus status;
  final UserCoordinates? coordinates;
  final bool usedLastKnownPosition;
}

abstract interface class LocationGateway {
  Future<bool> isLocationServiceEnabled();
  Future<AppLocationPermission> checkPermission();
  Future<AppLocationPermission> requestPermission();
  Future<UserCoordinates?> getCurrentPosition();
  Future<UserCoordinates?> getLastKnownPosition();
}

class GeolocatorLocationGateway implements LocationGateway {
  const GeolocatorLocationGateway();

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<AppLocationPermission> checkPermission() async =>
      _mapPermission(await Geolocator.checkPermission());

  @override
  Future<AppLocationPermission> requestPermission() async =>
      _mapPermission(await Geolocator.requestPermission());

  @override
  Future<UserCoordinates?> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return UserCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<UserCoordinates?> getLastKnownPosition() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return null;
    return UserCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  static AppLocationPermission _mapPermission(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.denied => AppLocationPermission.denied,
      LocationPermission.deniedForever => AppLocationPermission.deniedForever,
      LocationPermission.whileInUse => AppLocationPermission.whileInUse,
      LocationPermission.always => AppLocationPermission.always,
      LocationPermission.unableToDetermine => AppLocationPermission.denied,
    };
  }
}

class UserLocationService {
  const UserLocationService({
    this.gateway = const GeolocatorLocationGateway(),
    this.timeout = const Duration(seconds: 10),
  });

  final LocationGateway gateway;
  final Duration timeout;

  Future<UserLocationResult> locate() async {
    try {
      if (!await gateway.isLocationServiceEnabled()) {
        return const UserLocationResult.failure(
          UserLocationStatus.servicesDisabled,
        );
      }

      var permission = await gateway.checkPermission();
      if (permission == AppLocationPermission.denied) {
        permission = await gateway.requestPermission();
      }
      if (permission == AppLocationPermission.deniedForever) {
        return const UserLocationResult.failure(
          UserLocationStatus.permissionDeniedForever,
        );
      }
      if (permission == AppLocationPermission.denied) {
        return const UserLocationResult.failure(
          UserLocationStatus.permissionDenied,
        );
      }

      try {
        final current = await gateway.getCurrentPosition().timeout(timeout);
        if (current != null) return UserLocationResult.success(current);
      } on Object {
        // Fall through to the last-known position for a resilient demo flow.
      }

      try {
        final lastKnown = await gateway.getLastKnownPosition();
        if (lastKnown != null) {
          return UserLocationResult.success(
            lastKnown,
            usedLastKnownPosition: true,
          );
        }
      } on Object {
        // The result below communicates that no usable position was available.
      }
    } on Object {
      return const UserLocationResult.failure(UserLocationStatus.unavailable);
    }

    return const UserLocationResult.failure(UserLocationStatus.unavailable);
  }
}
