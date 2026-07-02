import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

class RoutePlan {
  final String from;
  final String to;
  final int travelTime;
  final int fare;
  final int stops;
  final String serviceInfo;
  final bool hasTransit;
  final List<String> steps;

  RoutePlan({
    required this.from,
    required this.to,
    required this.travelTime,
    required this.fare,
    required this.stops,
    required this.serviceInfo,
    required this.hasTransit,
    required this.steps,
  });
}

/// Mesin perutean sederhana untuk menghitung rute transit offline.
RoutePlan _calculateRoute(String from, String to) {
  final fromNorm = from.trim();
  final toNorm = to.trim();

  final lrtStations = ['Halim', 'Cawang', 'Setiabudi'];
  final krlStations = ['Tanah Abang', 'Manggarai', 'Setiabudi', 'Cawang'];
  final mrtStations = ['Bundaran HI', 'Setiabudi', 'Blok M'];

  bool isFromLrt = lrtStations.contains(fromNorm);
  bool isFromKrl = krlStations.contains(fromNorm);
  bool isFromMrt = mrtStations.contains(fromNorm);

  bool isToLrt = lrtStations.contains(toNorm);
  bool isToKrl = krlStations.contains(toNorm);
  bool isToMrt = mrtStations.contains(toNorm);

  if (fromNorm == toNorm) {
    return RoutePlan(
      from: fromNorm,
      to: toNorm,
      travelTime: 0,
      fare: 0,
      stops: 0,
      serviceInfo: 'Tidak butuh perjalanan',
      hasTransit: false,
      steps: ['Asal dan tujuan sama.'],
    );
  }

  // Helper untuk direct route
  RoutePlan? checkDirect(List<String> line, String lineName, bool isFrom, bool isTo) {
    if (isFrom && isTo) {
      final stopsCount = (line.indexOf(toNorm) - line.indexOf(fromNorm)).abs();
      final duration = stopsCount * 4;
      final price = 3000 + (stopsCount * 1000);
      return RoutePlan(
        from: fromNorm,
        to: toNorm,
        travelTime: duration,
        fare: price,
        stops: stopsCount,
        serviceInfo: '$lineName · Tanpa transit',
        hasTransit: false,
        steps: [
          'Naik $lineName dari Stasiun $fromNorm.',
          'Lewati $stopsCount stasiun perhentian.',
          'Tiba di Stasiun tujuan $toNorm.',
        ],
      );
    }
    return null;
  }

  // Cek direct route
  final mrtRoute = checkDirect(mrtStations, 'MRT Jakarta (Jalur Biru)', isFromMrt, isToMrt);
  if (mrtRoute != null) return mrtRoute;

  final krlRoute = checkDirect(krlStations, 'KRL Jabodetabek (Jalur Oranye)', isFromKrl, isToKrl);
  if (krlRoute != null) return krlRoute;

  final lrtRoute = checkDirect(lrtStations, 'LRT Jabodebek (Jalur Hijau)', isFromLrt, isToLrt);
  if (lrtRoute != null) return lrtRoute;

  // Kasus Transit di Setiabudi
  int stops1 = 0;
  int stops2 = 0;
  String line1 = '';
  String line2 = '';

  if (isFromMrt) {
    stops1 = (mrtStations.indexOf(fromNorm) - mrtStations.indexOf('Setiabudi')).abs();
    line1 = 'MRT Jakarta (Jalur Biru)';
  } else if (isFromKrl) {
    stops1 = (krlStations.indexOf(fromNorm) - krlStations.indexOf('Setiabudi')).abs();
    line1 = 'KRL Jabodetabek (Jalur Oranye)';
  } else {
    stops1 = (lrtStations.indexOf(fromNorm) - lrtStations.indexOf('Setiabudi')).abs();
    line1 = 'LRT Jabodebek (Jalur Hijau)';
  }

  if (isToMrt) {
    stops2 = (mrtStations.indexOf(toNorm) - mrtStations.indexOf('Setiabudi')).abs();
    line2 = 'MRT Jakarta (Jalur Biru)';
  } else if (isToKrl) {
    stops2 = (krlStations.indexOf(toNorm) - krlStations.indexOf('Setiabudi')).abs();
    line2 = 'KRL Jabodetabek (Jalur Oranye)';
  } else {
    stops2 = (lrtStations.indexOf(toNorm) - lrtStations.indexOf('Setiabudi')).abs();
    line2 = 'LRT Jabodebek (Jalur Hijau)';
  }

  final totalStops = stops1 + stops2;
  final duration = (totalStops * 4) + 5; // +5 menit waktu transit
  final price = 3000 + (totalStops * 1000) + 2000; // +Rp2.000 biaya integrasi/transit

  return RoutePlan(
    from: fromNorm,
    to: toNorm,
    travelTime: duration,
    fare: price,
    stops: totalStops,
    serviceInfo: '1 transit · Berpindah di Setiabudi',
    hasTransit: true,
    steps: [
      'Naik $line1 dari Stasiun $fromNorm.',
      'Turun di Stasiun Setiabudi ($stops1 stop).',
      'Transit di Setiabudi: Pindah ke peron $line2 (estimasi 5 mnt).',
      'Naik kereta ke arah Stasiun $toNorm ($stops2 stop).',
      'Tiba di Stasiun tujuan $toNorm.',
    ],
  );
}

/// Halaman Rute Tercepat (Screen 4 di Figma)
/// Menampilkan hasil rute dinamis berdasarkan stasiun asal & tujuan.
class RouteResultPage extends StatefulWidget {
  const RouteResultPage({super.key});

  @override
  State<RouteResultPage> createState() => _RouteResultPageState();
}

class _RouteResultPageState extends State<RouteResultPage> {
  String _selectedFilter = 'Tercepat';

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final from = uri.queryParameters['from'] ?? 'Setiabudi';
    final to = uri.queryParameters['to'] ?? 'Cawang';

    final route = _calculateRoute(from, to);

    // Format Rupiah
    final formattedFare = 'Rp${route.fare.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';

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
                          IconButton(
                            onPressed: () => context.go('/?selected=$from'),
                            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Expanded(
                            child: Text(
                              'Panduan Rute',
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

                    // ── Filter Chips ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterChip('Tercepat'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Minim transit'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Aksesibel'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Travel Time Info Card ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.kaiBlue,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kaiBlue.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimasi Perjalanan',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${route.travelTime}',
                                          style: const TextStyle(
                                            fontSize: 42,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.0,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 4, left: 6),
                                        child: Text(
                                          'menit',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4, left: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        route.serviceInfo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedFare,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Live ETA Card ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LiveEtaCard(
                        etaText: 'Kereta berikutnya datang 3 menit lagi',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Timeline Detail Rute Perjalanan ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTimelineWidget(route),
                    ),

                    const SizedBox(height: 20),

                    // ── Tombol Beli Tiket Tanpa Login ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go(
                              '/tiket?from=${Uri.encodeComponent(route.from)}'
                              '&to=${Uri.encodeComponent(route.to)}'
                              '&fare=${route.fare}'
                              '&duration=${route.travelTime}'
                              '&transit=${route.hasTransit ? "1" : "0"}',
                            );
                          },
                          icon: const Icon(Icons.confirmation_num_rounded, size: 20),
                          label: const Text(
                            'Beli tiket tanpa login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.buttonOrange.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Tombol Bacakan Rute & Lihat Peta ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Membacakan: Rute dari ${route.from} ke ${route.to} berdurasi ${route.travelTime} menit.'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.volume_up_rounded, size: 18),
                              label: const Text(
                                'Bacakan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/'),
                              icon: const Icon(Icons.map_rounded, size: 18),
                              label: const Text(
                                'Lihat peta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── A11Y Announcement Banner ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.a11yBannerBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'A11Y Live Region: Rute tercepat ${route.from} ke ${route.to} membutuhkan ${route.travelTime} menit dengan ${route.stops} pemberhentian.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.a11yBannerText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
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

  Widget _buildFilterChip(String label) {
    IconData? iconData;
    if (label == 'Tercepat') iconData = Icons.bolt_rounded;
    if (label == 'Minim transit') iconData = Icons.sync_alt_rounded;
    if (label == 'Aksesibel') iconData = Icons.accessible_rounded;

    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              Icon(
                iconData,
                size: 16,
                color: isSelected ? Colors.white : AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun Widget Timeline Perjalanan yang Dinamis
  Widget _buildTimelineWidget(RoutePlan route) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Rute Perjalanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...route.steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isLast = idx == route.steps.length - 1;

            Color dotColor = AppColors.statusAmber;
            if (isLast) {
              dotColor = AppColors.statusGreen;
            } else if (idx == 0) {
              dotColor = AppColors.primaryBlue;
            } else if (step.contains('MRT')) {
              dotColor = AppColors.badgeMRT;
            } else if (step.contains('LRT')) {
              dotColor = AppColors.badgeLRT;
            } else if (step.contains('KRL')) {
              dotColor = AppColors.badgeKRL;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    if (idx == 0)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: dotColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.trip_origin, size: 16, color: dotColor),
                      )
                    else if (isLast)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: dotColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.place, size: 16, color: dotColor),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    
                    if (!isLast)
                      Container(
                        width: 3,
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 2),
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: (idx == 0 || isLast)
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Card Live ETA tiruan
class LiveEtaCard extends StatelessWidget {
  final String etaText;

  const LiveEtaCard({
    super.key,
    required this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kereta berikutnya',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live ETA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            etaText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.statusGreen,
            ),
          ),
        ],
      ),
    );
  }
}
