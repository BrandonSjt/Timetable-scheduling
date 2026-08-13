import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/route_result/domain/services/route_speech_service.dart';
import 'helpers/route_test_data.dart';

void main() {
  test('Indonesian narration uses only backend route facts', () {
    final narration = buildRouteNarration(testRoute, 'id');
    expect(narration, contains('Bogor menuju Tangerang'));
    expect(narration, contains('134 menit'));
    expect(narration, contains('Rp10.000'));
    expect(narration, contains('KRL Lin Bogor'));
    expect(narration, contains('Transit di Duri'));
    expect(narration, contains('Tiba di Tangerang'));
  });

  test('English locale uses an English summary', () {
    final narration = buildRouteNarration(testRoute, 'en');
    expect(narration, startsWith('Route from Bogor to Tangerang.'));
    expect(narration, contains('Estimated travel time is 134 minutes.'));
  });
}
