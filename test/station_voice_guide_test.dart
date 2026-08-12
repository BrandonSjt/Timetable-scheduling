import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/search_station/domain/entities/station.dart';
import 'package:timetable/features/search_station/domain/services/station_voice_guide.dart';

const _station = Station(
  id: '1',
  slug: 'bogor',
  name: 'Bogor',
  shortName: 'Bogor',
  isLrt: false,
  isKrl: true,
  isMrt: false,
  isAccessible: true,
  publicCodes: ['B26'],
);

void main() {
  test('voice guide narrates result count and station name without code', () {
    expect(
      buildStationVoiceGuide(const [_station], 'id'),
      'Ditemukan 1 stasiun. Hasil teratas: Bogor.',
    );
  });

  test('voice guide limits narration to five results', () {
    final stations = List.generate(
      7,
      (index) => Station(
        id: '$index',
        slug: 'station-$index',
        name: 'Stasiun $index',
        shortName: 'Stasiun $index',
        isLrt: false,
        isKrl: true,
        isMrt: false,
        isAccessible: true,
        publicCodes: ['B$index'],
      ),
    );

    final narration = buildStationVoiceGuide(stations, 'id');
    expect(narration, startsWith('Ditemukan 7 stasiun. Hasil teratas:'));
    expect(narration, contains('Stasiun 4'));
    expect(narration, isNot(contains('kode')));
    expect(narration, isNot(contains('Stasiun 5')));
  });

  test('voice guide handles empty results in the active language', () {
    expect(
      buildStationVoiceGuide(const [], 'en'),
      'No stations match your search.',
    );
  });
}
