import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/presentation/widgets/map_widgets.dart';

/// Halaman Kereta / Train Map (Screen 1 di Figma)
/// Menampilkan peta skematik (warna pudar), search bar, tombol aksi stasiun,
/// dan info detail stasiun yang dipilih. Stasiun bisa diklik.
class TrainMapPage extends StatefulWidget {
  const TrainMapPage({super.key});

  @override
  State<TrainMapPage> createState() => _TrainMapPageState();
}

class _TrainMapPageState extends State<TrainMapPage> {
  String _selectedStation = 'Cawang';

  /// Data dummy info stasiun
  Map<String, Map<String, String>> _getStationData(AppLocalizations l10n) => {
    'Setiabudi': {'subtitle': l10n.mapSubtitleLrtKrl, 'lrtDest': 'Dukuh Atas', 'lrtDur': l10n.durationMinutes('3'), 'krlDest': 'Manggarai', 'krlDur': l10n.durationMinutes('7')},
    'Cawang': {'subtitle': l10n.mapSubtitleLrtKrl, 'lrtDest': 'Dukuh Atas', 'lrtDur': l10n.durationMinutes('5'), 'krlDest': 'Manggarai', 'krlDur': l10n.durationMinutes('9')},
    'Manggarai': {'subtitle': l10n.mapSubtitleKrlTransit, 'lrtDest': 'Setiabudi', 'lrtDur': l10n.durationMinutes('4'), 'krlDest': 'Tanah Abang', 'krlDur': l10n.durationMinutes('6')},
    'Tanah Abang': {'subtitle': l10n.mapSubtitleKrl, 'lrtDest': 'Manggarai', 'lrtDur': l10n.durationMinutes('6'), 'krlDest': 'Sudirman', 'krlDur': l10n.durationMinutes('3')},
    'Halim': {'subtitle': l10n.mapSubtitleLrt, 'lrtDest': 'Setiabudi', 'lrtDur': l10n.durationMinutes('8'), 'krlDest': 'Cawang', 'krlDur': l10n.durationMinutes('4')},
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = _getStationData(l10n)[_selectedStation]!;

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
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.textHint),
                              const SizedBox(width: 12),
                              Text(
                                l10n.mapSearchHint,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Peta Skematik (warna pudar, interaktif) ──
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: MapView(
                        showColors: false,
                        selectedStation: _selectedStation,
                        onStationSelected: (name) {
                          setState(() => _selectedStation = name);
                        },
                      ),
                    ),

                    // ── Tombol Aksi Stasiun (Dari, Lewat, Ke, Info) ──
                    const Center(child: StationActionBar()),

                    const SizedBox(height: 24),

                    // ── Info Detail Stasiun yang Dipilih ──
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
                          Text(
                            _selectedStation,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['subtitle']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TransitChip(
                                  lineType: 'LRT',
                                  destination: data['lrtDest']!,
                                  duration: data['lrtDur']!,
                                  lineColor: AppColors.badgeLRT,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TransitChip(
                                  lineType: 'KRL',
                                  destination: data['krlDest']!,
                                  duration: data['krlDur']!,
                                  lineColor: AppColors.badgeKRL,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
