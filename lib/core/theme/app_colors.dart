import 'package:flutter/material.dart';

/// Palet warna aplikasi KAI Access Prototype
/// Diambil dari desain Figma
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color primaryBlueLight = Color(0xFFDBEAFE);

  // ── Accent ──
  static const Color accentOrange = Color(0xFFED6B23);
  static const Color accentOrangeLight = Color(0xFFFFF7ED);

  // ── Accessibility (A11Y) ──
  static const Color a11yYellow = Color(0xFFFBBF24);
  static const Color a11yBannerBg = Color(0xFFFFF8E1);
  static const Color a11yBannerText = Color(0xFFE65100);

  // ── Transit Lines & Badges ──
  // KRL Commuter Line (5 jalur)
  static const Color lineBogor = Color(0xFFE53935);           // Red Line
  static const Color lineRangkasbitung = Color(0xFF43A047);   // Green Line
  static const Color lineTangerang = Color(0xFF795548);       // Brown Line
  static const Color lineCikarang = Color(0xFF1565C0);        // Blue Line
  static const Color lineTanjungPriok = Color(0xFFE91E63);    // Pink Line
  // MRT Jakarta
  static const Color lineMRT = Color(0xFF1E3A8A);             // Dark Blue
  // LRT Jabodebek
  static const Color lineLRT = Color(0xFFF58220);             // Orange (Batang Utama & Bekasi)
  static const Color lineLRTCibubur = Color(0xFFFFB74D);      // Light Orange (Cibubur)
  // LRT Jakarta
  static const Color lineLRTJakarta = Color(0xFF66BB6A);      // Light Green
  // Legacy aliases (untuk badge di UI lama)
  static const Color lineKRL = Color(0xFF10B981);             // KRL Badge Green
  static const Color badgeLRT = Color(0xFF2563EB);            // LRT Badge Blue
  static const Color badgeKRL = Color(0xFF10B981);            // KRL Badge Green
  static const Color badgeMRT = Color(0xFF1E3A8A);            // MRT Badge Dark Blue
  static const Color kaiBlue = Color(0xFF005BAC);             // KAI Blue

  // ── Neutral / Background ──
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE5E7EB);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Buttons ──
  static const Color buttonDark = Color(0xFF1E293B);
  static const Color buttonOrange = Color(0xFFF97316);

  // ── Status ──
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusAmber = Color(0xFFF59E0B);
  static const Color statusRed = Color(0xFFDC2626);
}
