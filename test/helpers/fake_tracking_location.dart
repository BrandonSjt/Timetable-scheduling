import 'dart:async';

import 'package:timetable/features/home/data/services/user_location_service.dart';

class FakeTrackingLocation implements LocationGateway {
  final positions = StreamController<UserCoordinates>.broadcast(sync: true);
  final services = StreamController<bool>.broadcast(sync: true);
  bool enabled = true;
  AppLocationPermission permission = AppLocationPermission.whileInUse;
  Future<AppLocationPermission>? pendingPermission;
  int permissionRequests = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<AppLocationPermission> checkPermission() async => permission;
  @override
  Future<AppLocationPermission> requestPermission() async {
    ++permissionRequests;
    return pendingPermission ?? permission;
  }

  @override
  Future<UserCoordinates?> getCurrentPosition() async => null;
  @override
  Future<UserCoordinates?> getLastKnownPosition() async => null;
  @override
  Stream<UserCoordinates> watchPosition() => positions.stream;
  @override
  Stream<bool> watchServiceEnabled() => services.stream;

  Future<void> dispose() async {
    await positions.close();
    await services.close();
  }
}
