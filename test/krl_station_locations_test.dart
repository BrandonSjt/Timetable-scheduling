import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/home/data/krl_station_locations.dart';
import 'package:timetable/shared/widgets/schematic_map_painter.dart';

void main() {
  const krlLineIds = {
    'bogor',
    'bogor_nambo',
    'cikarang_loop',
    'cikarang_east',
    'tangerang',
    'tanjung_priok',
    'rangkasbitung',
  };

  test('catalog contains 85 unique physical KRL station targets', () {
    final ids = krlStationLocations
        .map((station) => station.schematicStationId)
        .toSet();

    expect(krlStationLocations, hasLength(85));
    expect(ids, hasLength(krlStationLocations.length));
  });

  test('every coordinate points to an existing KRL schematic node', () {
    final stationById = {for (final station in stations) station.id: station};

    for (final location in krlStationLocations) {
      final schematic = stationById[location.schematicStationId];
      expect(
        schematic,
        isNotNull,
        reason: '${location.schematicStationId} is absent from the map',
      );
      expect(
        schematic!.lines.any(krlLineIds.contains),
        isTrue,
        reason: '${location.schematicStationId} is not assigned to a KRL line',
      );
    }
  });
}
