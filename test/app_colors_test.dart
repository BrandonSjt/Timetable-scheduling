import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/theme/app_colors.dart';
import 'package:timetable/core/theme/app_theme.dart';

void main() {
  test('KAI Access brand palette remains exact', () {
    expect(AppColors.gradientBlue, const Color(0xFF5A97EB));
    expect(AppColors.primaryPurple, const Color(0xFF7E4CDD));
    expect(AppColors.deepPurple, const Color(0xFF6E42DE));
    expect(AppColors.magenta, const Color(0xFFC84DAE));
    expect(AppColors.pinkAccent, const Color(0xFFCD599D));
    expect(AppColors.surface, const Color(0xFFFFFFFF));
    expect(AppColors.textPrimary, const Color(0xFF303040));
    expect(AppColors.cardBorder, const Color(0xFFE5E6EE));
    expect(AppColors.accentOrange, AppColors.deepPurple);
    expect(AppColors.buttonOrange, AppColors.primaryPurple);
  });

  test('main gradient uses the approved colors and stops', () {
    expect(AppColors.primaryGradient.colors, const [
      Color(0xFF5A97EB),
      Color(0xFF7E4CDD),
      Color(0xFFC84DAE),
    ]);
    expect(AppColors.primaryGradient.stops, const [0, 0.55, 1]);
    expect(AppColors.primaryGradient.begin, Alignment.topLeft);
    expect(AppColors.primaryGradient.end, Alignment.bottomRight);
  });

  test('Material theme exposes the brand roles', () {
    final theme = AppTheme.lightTheme;

    expect(theme.colorScheme.primary, AppColors.primaryPurple);
    expect(theme.colorScheme.secondary, AppColors.magenta);
    expect(theme.colorScheme.tertiary, AppColors.gradientBlue);
    expect(theme.colorScheme.outline, AppColors.cardBorder);
    expect(
      theme.bottomNavigationBarTheme.selectedItemColor,
      AppColors.primaryPurple,
    );
  });

  test('official transport colors remain unchanged', () {
    expect(AppColors.lineBogor, const Color(0xFFE53935));
    expect(AppColors.lineRangkasbitung, const Color(0xFF43A047));
    expect(AppColors.lineTangerang, const Color(0xFF795548));
    expect(AppColors.lineCikarang, const Color(0xFF00BCD4));
    expect(AppColors.lineTanjungPriok, const Color(0xFFE91E63));
    expect(AppColors.lineMRT, const Color(0xFFD81B60));
    expect(AppColors.lineLRTBekasi, const Color(0xFF007E33));
    expect(AppColors.lineLRTCibubur, const Color(0xFF003399));
    expect(AppColors.lineLRTJakarta, const Color(0xFFF16522));
  });
}
