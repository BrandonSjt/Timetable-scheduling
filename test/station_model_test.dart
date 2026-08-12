import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/search_station/data/models/station_model.dart';

void main() {
  test(
    'station model prefers official identity and preserves public codes',
    () {
      final station = StationModel.fromJson({
        'id': 'station-1',
        'slug': 'tanjung-priok',
        'name': 'Tanjung Priok',
        'shortName': 'Tanjung Priok',
        'officialName': 'Tanjung Priok',
        'operationalCode': 'TPK',
        'isKrl': true,
        'isAccessible': true,
        'publicCodes': [
          {'code': 'TP04'},
        ],
      });

      expect(station.name, 'Tanjung Priok');
      expect(station.operationalCode, 'TPK');
      expect(station.codes, 'TP04');
      expect(station.isKrl, isTrue);
    },
  );
}
