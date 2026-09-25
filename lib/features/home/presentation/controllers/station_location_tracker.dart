import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/services/user_location_service.dart';
import '../../domain/entities/station_geo_point.dart';
import '../../domain/services/nearest_krl_station.dart';

/// Station approximation only. Never use this as an indoor walking instruction.
class StationLocationTracker extends ChangeNotifier {
  StationLocationTracker({
    required this.service,
    required this.stations,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final UserLocationService service;
  final List<StationGeoPoint> stations;
  final DateTime Function() now;
  NearestKrlStationResult? nearby;
  UserLocationStatus? failure;
  bool loading = false;
  bool active = false;
  StreamSubscription<UserCoordinates>? _positions;
  StreamSubscription<bool>? _services;
  Timer? _deadline;
  int _generation = 0;
  bool _disposed = false;

  Future<void> start({bool requestPermission = false}) async {
    final generation = ++_generation;
    active = true;
    nearby = null;
    failure = null;
    loading = true;
    _deadline?.cancel();
    final positions = _positions;
    final services = _services;
    _positions = null;
    _services = null;
    _notify();
    await _cancel(positions);
    await _cancel(services);
    if (!_current(generation)) return;
    final status = await service.prepare(requestPermission: requestPermission);
    if (!_current(generation)) return;
    if (status != UserLocationStatus.success) {
      _fail(status);
      return;
    }
    try {
      _deadline = Timer(service.timeout, () {
        if (_current(generation)) {
          loading = false;
          failure = UserLocationStatus.unavailable;
          _notify();
        }
      });
      _positions = service.gateway.watchPosition().listen(
        (position) {
          if (!_current(generation)) return;
          _deadline?.cancel();
          loading = false;
          failure = null;
          nearby = NearestKrlStation.findNearby(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracyMeters: position.accuracyMeters,
            timestamp: position.timestamp,
            now: now(),
            stations: stations,
          );
          if (nearby != null) {
            final remaining = position.timestamp!
                .add(NearestKrlStation.maxPositionAge)
                .difference(now());
            _deadline = Timer(
              remaining.isNegative ? Duration.zero : remaining,
              () {
                if (_current(generation)) {
                  nearby = null;
                  failure = UserLocationStatus.unavailable;
                  _notify();
                }
              },
            );
          }
          _notify();
        },
        onError: (Object error) {
          if (_current(generation)) _fail(UserLocationStatus.unavailable);
        },
        onDone: () {
          if (_current(generation)) _fail(UserLocationStatus.unavailable);
        },
      );
      _services = service.gateway.watchServiceEnabled().listen(
        (enabled) {
          if (_current(generation) && !enabled) {
            _fail(UserLocationStatus.servicesDisabled);
          }
        },
        onError: (Object error) {
          if (_current(generation)) _fail(UserLocationStatus.unavailable);
        },
      );
    } on Object {
      if (_current(generation)) _fail(UserLocationStatus.unavailable);
    }
  }

  bool _current(int generation) =>
      !_disposed && active && generation == _generation;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _fail(UserLocationStatus status) {
    stop();
    failure = status;
    _notify();
  }

  void stop() {
    ++_generation;
    active = false;
    nearby = null;
    failure = null;
    loading = false;
    _deadline?.cancel();
    _deadline = null;
    unawaited(_cancel(_positions));
    unawaited(_cancel(_services));
    _positions = null;
    _services = null;
    _notify();
  }

  Future<void> _cancel(StreamSubscription<dynamic>? subscription) async {
    try {
      await subscription?.cancel();
    } on Object {
      // The marker is already invalidated. Plugin cleanup errors must not crash
      // the app or make an old callback eligible to publish a location.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }
}
