import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/home/data/services/user_location_service.dart';

void main() {
  test('returns disabled when device location services are off', () async {
    final gateway = FakeLocationGateway(serviceEnabled: false);

    final result = await UserLocationService(gateway: gateway).locate();

    expect(result.status, UserLocationStatus.servicesDisabled);
    expect(gateway.requestPermissionCalls, 0);
  });

  test('requests permission and returns denied when user refuses', () async {
    final gateway = FakeLocationGateway(
      checkedPermission: AppLocationPermission.denied,
      requestedPermission: AppLocationPermission.denied,
    );

    final result = await UserLocationService(gateway: gateway).locate();

    expect(result.status, UserLocationStatus.permissionDenied);
    expect(gateway.requestPermissionCalls, 1);
  });

  test('returns permanently denied without requesting again', () async {
    final gateway = FakeLocationGateway(
      checkedPermission: AppLocationPermission.deniedForever,
    );

    final result = await UserLocationService(gateway: gateway).locate();

    expect(result.status, UserLocationStatus.permissionDeniedForever);
    expect(gateway.requestPermissionCalls, 0);
  });

  test('returns current coordinates when permission is granted', () async {
    const coordinates = UserCoordinates(latitude: -6.2102, longitude: 106.8499);
    final gateway = FakeLocationGateway(currentPosition: coordinates);

    final result = await UserLocationService(gateway: gateway).locate();

    expect(result.status, UserLocationStatus.success);
    expect(result.coordinates, coordinates);
    expect(result.usedLastKnownPosition, isFalse);
  });

  test(
    'falls back to last-known position when current position fails',
    () async {
      const fallback = UserCoordinates(latitude: -6.2, longitude: 106.8);
      final gateway = FakeLocationGateway(
        currentError: const LocationException(),
        lastKnownPosition: fallback,
      );

      final result = await UserLocationService(gateway: gateway).locate();

      expect(result.status, UserLocationStatus.success);
      expect(result.coordinates, fallback);
      expect(result.usedLastKnownPosition, isTrue);
    },
  );

  test(
    'returns unavailable when current and last-known positions fail',
    () async {
      final gateway = FakeLocationGateway(
        currentError: const LocationException(),
      );

      final result = await UserLocationService(gateway: gateway).locate();

      expect(result.status, UserLocationStatus.unavailable);
    },
  );
}

class LocationException implements Exception {
  const LocationException();
}

class FakeLocationGateway implements LocationGateway {
  FakeLocationGateway({
    this.serviceEnabled = true,
    this.checkedPermission = AppLocationPermission.whileInUse,
    this.requestedPermission = AppLocationPermission.whileInUse,
    this.currentPosition,
    this.lastKnownPosition,
    this.currentError,
  });

  final bool serviceEnabled;
  final AppLocationPermission checkedPermission;
  final AppLocationPermission requestedPermission;
  final UserCoordinates? currentPosition;
  final UserCoordinates? lastKnownPosition;
  final Object? currentError;
  int requestPermissionCalls = 0;

  @override
  Future<AppLocationPermission> checkPermission() async => checkedPermission;

  @override
  Future<UserCoordinates?> getCurrentPosition() async {
    if (currentError != null) throw currentError!;
    return currentPosition;
  }

  @override
  Future<UserCoordinates?> getLastKnownPosition() async => lastKnownPosition;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<AppLocationPermission> requestPermission() async {
    requestPermissionCalls += 1;
    return requestedPermission;
  }
}
