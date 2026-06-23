import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

/// Halaman Promo (Screen 10 di Figma)
/// Menampilkan daftar promosi dan voucher diskon perjalanan KAI
class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color headerBgColor = Color(0xFF4F46E5); // Vibrant Indigo/Blue-Purple

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey/blue background from design
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Area ──
            Container(
              width: double.infinity,
              color: headerBgColor,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top scan & ID circular buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'Scan',
                            style: TextStyle(
                              color: headerBgColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'ID',
                            style: TextStyle(
                              color: headerBgColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Promo',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Voucher dan penawaran perjalanan',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body Cards List ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  _buildPromoCard(
                    title: 'Promo KRL + LRT',
                    subtitle:
                        'Diskon demo 20% untuk pembelian tiket tanpa login sampai hari ini.',
                    badgeText: 'Guest bisa pakai',
                    badgeBgColor: const Color(0xFFFFF7ED),
                    badgeTextColor: const Color(0xFFC2410C),
                  ),
                  const SizedBox(height: 16),
                  _buildPromoCard(
                    title: 'Aksesibilitas',
                    subtitle:
                        'Mode kontras tinggi, bacakan rute, dan rute tanpa peta tersedia di semua',
                    badgeText: 'Fitur utama',
                    badgeBgColor: const Color(0xFFEFF6FF),
                    badgeTextColor: const Color(0xFF1D4ED8),
                  ),
                  const SizedBox(height: 16),
                  _buildPromoCard(
                    title: 'Lanjut transport',
                    subtitle:
                        'Info halte, exit, dan titik jemput setelah turun di stasiun.',
                    badgeText: 'Antarmoda',
                    badgeBgColor: const Color(0xFFECFDF5),
                    badgeTextColor: const Color(0xFF047857),
                  ),
                ],
              ),
            ),

            // ── Bottom Navigation Bar ──
            const AppBottomNavBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
