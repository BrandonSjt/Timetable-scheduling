import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/home/domain/entities/station_geo_point.dart';
import 'package:timetable/features/home/domain/services/nearest_krl_station.dart';

void main() {
  const stations = [
    StationGeoPoint(
      schematicStationId: 'manggarai_cb',
      name: 'Manggarai',
      latitude: -6.2102,
      longitude: 106.8499,
    ),
    StationGeoPoint(
      schematicStationId: 'tebet',
      name: 'Tebet',
      latitude: -6.2264,
      longitude: 106.8584,
    ),
  ];

  double simpleDistance(double lat1, double lon1, double lat2, double lon2) {
    final lat = lat1 - lat2;
    final lon = lon1 - lon2;
    return (lat * lat) + (lon * lon);
  }

  test('selects the nearest KRL physical station', () {
    final result = NearestKrlStation.find(
      latitude: -6.211,
      longitude: 106.850,
      stations: stations,
      distanceBetween: simpleDistance,
    );

    expect(result?.station.schematicStationId, 'manggarai_cb');
  });

  test('returns null for an empty station catalog', () {
    final result = NearestKrlStation.find(
      latitude: -6.2,
      longitude: 106.8,
      stations: const [],
      distanceBetween: simpleDistance,
    );

    expect(result, isNull);
  });

  test('uses one canonical schematic id for a physical interchange', () {
    final duplicateIds = stations
        .where((station) => station.name == 'Manggarai')
        .map((station) => station.schematicStationId)
        .toSet();

    expect(duplicateIds, {'manggarai_cb'});
  });
}
