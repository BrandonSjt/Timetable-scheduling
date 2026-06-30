import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/map_widgets.dart';

/// Data dummy info stasiun untuk ditampilkan saat stasiun diklik
class _StationInfo {
  final String name;
  final String lrtDest;
  final String lrtDur;
  final String krlDest;
  final String krlDur;

  const _StationInfo({
    required this.name,
    required this.lrtDest,
    required this.lrtDur,
    required this.krlDest,
    required this.krlDur,
  });
}

const Map<String, _StationInfo> _stationInfoMap = {
  'Setiabudi': _StationInfo(
    name: 'Setiabudi',
    lrtDest: 'Dukuh Atas', lrtDur: '3 menit',
    krlDest: 'Manggarai', krlDur: '7 menit',
  ),
  'Cawang': _StationInfo(
    name: 'Cawang',
    lrtDest: 'Dukuh Atas', lrtDur: '5 menit',
    krlDest: 'Manggarai', krlDur: '9 menit',
  ),
  'Manggarai': _StationInfo(
    name: 'Manggarai',
    lrtDest: 'Setiabudi', lrtDur: '4 menit',
    krlDest: 'Tanah Abang', krlDur: '6 menit',
  ),
  'Tanah Abang': _StationInfo(
    name: 'Tanah Abang',
    lrtDest: 'Manggarai', lrtDur: '6 menit',
    krlDest: 'Sudirman', krlDur: '3 menit',
  ),
  'Halim': _StationInfo(
    name: 'Halim',
    lrtDest: 'Setiabudi', lrtDur: '8 menit',
    krlDest: 'Cawang', krlDur: '4 menit',
  ),
};

/// Halaman Beranda (Screen 3 di Figma)
/// Menampilkan peta skematik berwarna, filter jalur, info stasiun terdekat,
/// dan banner aksesibilitas. Stasiun di peta bisa diklik.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedStation = 'Setiabudi';

  void _onStationSelected(String stationName) {
    setState(() {
      _selectedStation = stationName;
    });
    // Update URL query parameter to keep everything in sync
    context.go('/?selected=$stationName');
  }

  @override
  Widget build(BuildContext context) {
    final selectedParam = GoRouterState.of(context).uri.queryParameters['selected'];
    final currentStation = (selectedParam != null && _stationInfoMap.containsKey(selectedParam))
        ? selectedParam
        : _selectedStation;

    final info = _stationInfoMap[currentStation]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Konten scrollable ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Search Bar ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () => context.go('/cari-stasiun'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: AppColors.textHint),
                              SizedBox(width: 12),
                              Text(
                                'Cari stasiun LRT atau KRL',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Filter Chips ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          LineFilterChip(label: 'LRT Jabodebek', isSelected: true),
                          SizedBox(width: 8),
                          LineFilterChip(label: 'KRL Jabodetabek', isSelected: false),
                          SizedBox(width: 8),
                          LineFilterChip(label: 'Kontras', isDark: true),
                        ],
                      ),
                    ),

                    // ── Peta Skematik (berwarna, interaktif) ──
                    MapView(
                      showColors: true,
                      selectedStation: currentStation,
                      onStationSelected: _onStationSelected,
                    ),

                    // ── Info Stasiun yang Dipilih ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stasiun terdekat',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                info.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => context.go('/cari-stasiun?action=select_destination&from=$currentStation'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Pilih dari sini',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Transit Chips ──
                          Row(
                            children: [
                              Expanded(
                                child: TransitChip(
                                  lineType: 'LRT',
                                  destination: info.lrtDest,
                                  duration: info.lrtDur,
                                  lineColor: AppColors.badgeLRT,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TransitChip(
                                  lineType: 'KRL',
                                  destination: info.krlDest,
                                  duration: info.krlDur,
                                  lineColor: AppColors.badgeKRL,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── A11Y Banner ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.a11yBannerBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'A11Y: Ada daftar rute dan tombol bacakan, peta bukan satu-satunya navigasi.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.a11yBannerText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Navigation Bar ──
            const AppBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}
