import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/station_card.dart';

/// Halaman Cari Stasiun (Screen 2 di Figma)
/// Menampilkan search bar, filter layanan, daftar stasiun,
/// dan banner login lokal.
class SearchStationPage extends StatelessWidget {
  const SearchStationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── App Bar Custom ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/'),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Cari stasiun',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // ── A11Y Button ──
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.a11yYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'A11Y',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Search Bar ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ketik nama stasiun, jalur, atau area',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Filter Layanan ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Filter layanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const ServiceFilterChip(label: 'Semua', isSelected: false),
                          const SizedBox(width: 8),
                          const ServiceFilterChip(label: 'LRT', isSelected: false),
                          const SizedBox(width: 8),
                          const ServiceFilterChip(label: 'KRL', isSelected: true),
                          const SizedBox(width: 8),
                          const ServiceFilterChip(label: 'Aksesibel', isSelected: false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Hasil Cepat ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hasil cepat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Daftar Stasiun ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          StationCard(
                            name: 'Setiabudi',
                            lineInfo: 'LRT Jabodebek',
                            statusText: 'Lift tersedia · 3 menit',
                            statusColor: AppColors.statusGreen,
                          ),
                          StationCard(
                            name: 'Manggarai',
                            lineInfo: 'KRL · Transit utama',
                            statusText: 'Kepadatan sedang · 6 menit',
                            statusColor: AppColors.statusAmber,
                          ),
                          StationCard(
                            name: 'Cawang',
                            lineInfo: 'LRT + KRL',
                            statusText: 'Transit aksesibel · 8 menit',
                            statusColor: AppColors.primaryBlue,
                          ),
                          StationCard(
                            name: 'Tanah Abang',
                            lineInfo: 'KRL Jabodetabek',
                            statusText: 'Peron ramai · 5 menit',
                            statusColor: AppColors.statusAmber,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Banner Tanpa Login ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.a11yBannerBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanpa login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.a11yBannerText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Favorit dan riwayat disimpan lokal di perangkat.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Navigation Bar ──
            const AppBottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}
