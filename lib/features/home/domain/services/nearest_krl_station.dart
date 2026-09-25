import 'dart:math' as math;

import '../entities/station_geo_point.dart';

typedef StationDistanceBetween =
    double Function(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
    );

class NearestKrlStationResult {
  const NearestKrlStationResult({
    required this.station,
    required this.distanceMeters,
  });

  final StationGeoPoint station;
  final double distanceMeters;
}

abstract final class NearestKrlStation {
  static const nearbyRadiusMeters = 300.0;
  static const maxAccuracyMeters = 100.0;
  static const maxPositionAge = Duration(seconds: 30);

  static NearestKrlStationResult? findNearby({
    required double latitude,
    required double longitude,
    required double? accuracyMeters,
    required DateTime? timestamp,
    required DateTime now,
    required List<StationGeoPoint> stations,
    double radiusMeters = nearbyRadiusMeters,
  }) {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude.abs() > 90 ||
        longitude.abs() > 180 ||
        accuracyMeters == null ||
        !accuracyMeters.isFinite ||
        accuracyMeters < 0 ||
        accuracyMeters > maxAccuracyMeters ||
        timestamp == null ||
        timestamp.isAfter(now) ||
        now.difference(timestamp) >= maxPositionAge ||
        !radiusMeters.isFinite ||
        radiusMeters <= 0) {
      return null;
    }

    final closest = find(
      latitude: latitude,
      longitude: longitude,
      stations: stations,
    );
    if (closest == null ||
        closest.distanceMeters + accuracyMeters > radiusMeters) {
      return null;
    }
    final second = find(
      latitude: latitude,
      longitude: longitude,
      stations: stations
          .where(
            (s) => s.schematicStationId != closest.station.schematicStationId,
          )
          .toList(),
    );
    if (second != null &&
        second.distanceMeters - closest.distanceMeters <= 2 * accuracyMeters) {
      return null;
    }
    return closest;
  }

  static NearestKrlStationResult? find({
    required double latitude,
    required double longitude,
    required List<StationGeoPoint> stations,
    StationDistanceBetween distanceBetween = _haversineDistance,
  }) {
    if (stations.isEmpty) return null;

    StationGeoPoint nearest = stations.first;
    var shortestDistance = distanceBetween(
      latitude,
      longitude,
      nearest.latitude,
      nearest.longitude,
    );

    for (final station in stations.skip(1)) {
      final distance = distanceBetween(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );
      if (distance < shortestDistance) {
        nearest = station;
        shortestDistance = distance;
      }
    }

    return NearestKrlStationResult(
      station: nearest,
      distanceMeters: shortestDistance,
    );
  }

  static double _haversineDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusMeters = 6371000.0;
    final deltaLatitude = _radians(endLatitude - startLatitude);
    final deltaLongitude = _radians(endLongitude - startLongitude);
    final startLat = _radians(startLatitude);
    final endLat = _radians(endLatitude);
    final a =
        math.sin(deltaLatitude / 2) * math.sin(deltaLatitude / 2) +
        math.cos(startLat) *
            math.cos(endLat) *
            math.sin(deltaLongitude / 2) *
            math.sin(deltaLongitude / 2);
    return earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
