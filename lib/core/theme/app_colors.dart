import 'package:flutter/material.dart';

/// Sistem warna aplikasi berdasarkan palet KAI Access.
class AppColors {
  AppColors._();

  // ── Brand palette ──
  static const Color gradientBlue = Color(0xFF5A97EB);
  static const Color primaryPurple = Color(0xFF7E4CDD);
  static const Color deepPurple = Color(0xFF6E42DE);
  static const Color magenta = Color(0xFFC84DAE);
  static const Color pinkAccent = Color(0xFFCD599D);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientBlue, primaryPurple, magenta],
    stops: [0, 0.55, 1],
  );

  // Compatibility aliases untuk widget yang sudah ada.
  static const Color primaryBlue = primaryPurple;
  static const Color primaryBlueDark = deepPurple;
  static const Color primaryBlueLight = Color(0xFFF1ECFC);

  // ── Accent ──
  static const Color accentOrange = deepPurple;
  static const Color accentOrangeLight = Color(0xFFFBEFF8);

  // ── Accessibility (A11Y) ──
  static const Color a11yYellow = Color(0xFFFBBF24);
  static const Color a11yBannerBg = Color(0xFFFFF8E1);
  static const Color a11yBannerText = Color(0xFFE65100);

  // ── Transit Lines & Badges ──
  // KRL Commuter Line (5 jalur)
  static const Color lineBogor = Color(0xFFE53935); // Red Line
  static const Color lineRangkasbitung = Color(0xFF43A047); // Green Line
  static const Color lineTangerang = Color(0xFF795548); // Brown Line
  static const Color lineCikarang = Color(0xFF00BCD4); // Cyan Line
  static const Color lineTanjungPriok = Color(0xFFE91E63); // Pink Line
  // MRT Jakarta
  static const Color lineMRT = Color(0xFFD81B60); // Pink-Red
  // LRT Jabodebek
  static const Color lineLRTBekasi = Color(0xFF007E33); // Forest Green (Bekasi)
  static const Color lineLRTCibubur = Color(0xFF003399); // Royal Blue (Cibubur)
  // LRT Jakarta
  static const Color lineLRTJakarta = Color(0xFFF16522); // Orange LRT Jakarta
  // Legacy aliases (untuk badge di UI lama)
  static const Color lineKRL = Color(0xFF10B981); // KRL Badge Green
  static const Color badgeLRT = Color(0xFF2563EB); // LRT Badge Blue
  static const Color badgeKRL = Color(0xFF10B981); // KRL Badge Green
  static const Color badgeMRT = Color(0xFF1E3A8A); // MRT Badge Dark Blue
  static const Color kaiBlue = Color(0xFF005BAC); // KAI Blue

  // ── Neutral / Background ──
  static const Color background = Color(0xFFF8F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E6EE);
  static const Color divider = cardBorder;

  // ── Text ──
  static const Color textPrimary = Color(0xFF303040);
  static const Color textSecondary = Color(0xFF666677);
  static const Color textHint = Color(0xFF737384);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Buttons ──
  static const Color buttonDark = textPrimary;
  static const Color buttonOrange = primaryPurple;

  // ── Status ──
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusAmber = Color(0xFFF59E0B);
  static const Color statusRed = Color(0xFFDC2626);
}
