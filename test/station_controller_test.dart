import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/search_station/domain/entities/station.dart';
import 'package:timetable/features/search_station/domain/repositories/station_repository.dart';
import 'package:timetable/features/search_station/presentation/controllers/station_controller.dart';

class _Repository implements StationRepository {
  @override
  Future<List<Station>> getStations() async => const [
    Station(
      id: '1',
      slug: 'bogor',
      name: 'Bogor',
      shortName: 'Bogor',
      isLrt: false,
      isKrl: true,
      isMrt: false,
      isAccessible: true,
      publicCodes: ['B26'],
    ),
    Station(
      id: '2',
      slug: 'asean',
      name: 'ASEAN Headquarters',
      shortName: 'ASEAN HQ',
      isLrt: false,
      isKrl: false,
      isMrt: true,
      isAccessible: true,
      publicCodes: ['M07'],
    ),
  ];
}

void main() {
  test('controller filters API catalog by service, alias, and code', () async {
    final controller = StationController(_Repository());
    await controller.load();
    controller.selectFilter('MRT');
    controller.search('M07');
    expect(controller.filtered().single.slug, 'asean');
    controller.search('ASEAN HQ');
    expect(controller.filtered().single.name, 'ASEAN Headquarters');
  });
}
