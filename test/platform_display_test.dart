import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/timetable/domain/services/platform_display.dart';

void main() {
  test('empty and placeholder platforms are unavailable', () {
    expect(PlatformDisplay.isAvailable(''), isFalse);
    expect(PlatformDisplay.isAvailable('   '), isFalse);
    expect(PlatformDisplay.isAvailable('-'), isFalse);
    expect(PlatformDisplay.isAvailable('n/a'), isFalse);
    expect(PlatformDisplay.isAvailable(null), isFalse);
  });

  test('verified platforms keep the Peron label', () {
    expect(PlatformDisplay.isAvailable('5'), isTrue);
    expect(PlatformDisplay.isAvailable('5/6'), isTrue);
    expect(PlatformDisplay.label('5'), 'Peron 5');
    expect(PlatformDisplay.label(' 5/6 '), 'Peron 5/6');
  });

  test('missing platforms use the honest fallback copy', () {
    expect(PlatformDisplay.label(''), 'Peron belum tersedia');
    expect(PlatformDisplay.label('-'), 'Peron belum tersedia');
    expect(PlatformDisplay.checkBoardHint, 'Cek papan informasi stasiun');
  });
}
