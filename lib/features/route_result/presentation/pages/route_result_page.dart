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

  final lrtStations = ['Tanah Abang', 'Manggarai', 'Setiabudi'];
  final krlStations = ['Halim', 'Setiabudi', 'Cawang'];

  final isFromLrt = lrtStations.contains(fromNorm);
  final isFromKrl = krlStations.contains(fromNorm);
  final isToLrt = lrtStations.contains(toNorm);
  final isToKrl = krlStations.contains(toNorm);

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

  // Kasus 1: Keduanya berada di jalur LRT
  if (isFromLrt && isToLrt) {
    final stopsCount = (lrtStations.indexOf(toNorm) - lrtStations.indexOf(fromNorm)).abs();
    final duration = stopsCount * 4;
    final price = 3000 + (stopsCount * 1000);
    return RoutePlan(
      from: fromNorm,
      to: toNorm,
      travelTime: duration,
      fare: price,
      stops: stopsCount,
      serviceInfo: 'LRT Jabodebek · Tanpa transit',
      hasTransit: false,
      steps: [
        'Naik LRT Jabodebek (Jalur Hijau) dari Stasiun $fromNorm.',
        'Lewati $stopsCount stasiun perhentian.',
        'Tiba di Stasiun tujuan $toNorm.',
      ],
    );
  }

  // Kasus 2: Keduanya berada di jalur KRL
  if (isFromKrl && isToKrl) {
    final stopsCount = (krlStations.indexOf(toNorm) - krlStations.indexOf(fromNorm)).abs();
    final duration = stopsCount * 4;
    final price = 3000 + (stopsCount * 1000);
    return RoutePlan(
      from: fromNorm,
      to: toNorm,
      travelTime: duration,
      fare: price,
      stops: stopsCount,
      serviceInfo: 'KRL Jabodetabek · Tanpa transit',
      hasTransit: false,
      steps: [
        'Naik KRL Jabodetabek (Jalur Oranye) dari Stasiun $fromNorm.',
        'Lewati $stopsCount stasiun perhentian.',
        'Tiba di Stasiun tujuan $toNorm.',
      ],
    );
  }

  // Kasus 3: Butuh transit di Setiabudi (LRT ⇄ KRL)
  int stops1 = 0;
  int stops2 = 0;
  String line1 = '';
  String line2 = '';

  if (isFromLrt) {
    stops1 = (lrtStations.indexOf(fromNorm) - lrtStations.indexOf('Setiabudi')).abs();
    line1 = 'LRT Jabodebek (Jalur Hijau)';
  } else {
    stops1 = (krlStations.indexOf(fromNorm) - krlStations.indexOf('Setiabudi')).abs();
    line1 = 'KRL Jabodetabek (Jalur Oranye)';
  }

  if (isToLrt) {
    stops2 = (lrtStations.indexOf(toNorm) - lrtStations.indexOf('Setiabudi')).abs();
    line2 = 'LRT Jabodebek (Jalur Hijau)';
  } else {
    stops2 = (krlStations.indexOf(toNorm) - krlStations.indexOf('Setiabudi')).abs();
    line2 = 'KRL Jabodetabek (Jalur Oranye)';
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
                          GestureDetector(
                            onTap: () => context.go('/?selected=$from'),
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

                    // ── Travel Time Info ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimasi Perjalanan',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${route.travelTime}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.0,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6, left: 4),
                                child: Text(
                                  'menit',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      route.serviceInfo,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      formattedFare,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
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
                        child: ElevatedButton(
                          onPressed: () {
                            context.go(
                              '/tiket?from=${Uri.encodeComponent(route.from)}'
                              '&to=${Uri.encodeComponent(route.to)}'
                              '&fare=${route.fare}'
                              '&duration=${route.travelTime}'
                              '&transit=${route.hasTransit ? "1" : "0"}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Beli tiket tanpa login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
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
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Membacakan: Rute dari ${route.from} ke ${route.to} berdurasi ${route.travelTime} menit.'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Bacakan rute',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.go('/'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Lihat peta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
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
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryBlue,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
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

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: idx == 0
                            ? AppColors.primaryBlue
                            : isLast
                                ? AppColors.statusGreen
                                : AppColors.statusAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 44,
                        color: AppColors.cardBorder,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: (idx == 0 || isLast)
                            ? FontWeight.w600
                            : FontWeight.w400,
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
