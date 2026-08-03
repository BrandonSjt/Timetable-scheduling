import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../l10n/app_localizations.dart';

class RoutePlanStep {
  final String text;
  final String durationText;
  final String detailNote;
  final IconData icon;
  final Color color;
  final bool isHeader;
  final bool isTransit;
  final bool isDestination;

  RoutePlanStep({
    required this.text,
    required this.durationText,
    required this.detailNote,
    required this.icon,
    required this.color,
    this.isHeader = false,
    this.isTransit = false,
    this.isDestination = false,
  });
}

class RoutePlan {
  final String from;
  final String to;
  final int travelTime;
  final int fare;
  final int stops;
  final String serviceInfo;
  final bool hasTransit;
  final List<RoutePlanStep> steps;
  final String exitGateA;
  final String exitGateB;

  RoutePlan({
    required this.from,
    required this.to,
    required this.travelTime,
    required this.fare,
    required this.stops,
    required this.serviceInfo,
    required this.hasTransit,
    required this.steps,
    required this.exitGateA,
    required this.exitGateB,
  });
}

/// Mesin perutean sederhana untuk menghitung rute transit offline.
RoutePlan _calculateRoute(String from, String to, AppLocalizations l10n) {
  final fromNorm = from.trim();
  final toNorm = to.trim();

  final lrtStations = ['Halim', 'Cawang', 'Setiabudi', 'Taman Mini', 'Harjamukti', 'Jati Mulya'];
  final krlStations = ['Tanah Abang', 'Manggarai', 'Setiabudi', 'Cawang', 'Bekasi', 'Bogor', 'Cikarang'];
  final mrtStations = ['Bundaran HI', 'Setiabudi', 'Blok M', 'Lebak Bulus'];

  bool isFromLrt = lrtStations.contains(fromNorm);
  bool isFromKrl = krlStations.contains(fromNorm);
  bool isFromMrt = mrtStations.contains(fromNorm);

  bool isToLrt = lrtStations.contains(toNorm);
  bool isToKrl = krlStations.contains(toNorm);
  bool isToMrt = mrtStations.contains(toNorm);

  final defaultGateA = l10n.mainAccessGate;
  final defaultGateB = l10n.dropOffGate;

  if (fromNorm == toNorm) {
    return RoutePlan(
      from: fromNorm,
      to: toNorm,
      travelTime: 0,
      fare: 0,
      stops: 0,
      serviceInfo: l10n.noTripNeeded,
      hasTransit: false,
      steps: [
        RoutePlanStep(
          text: l10n.sameOriginDest,
          durationText: '0 ${l10n.minuteShort}',
          detailNote: l10n.alreadyAtDest,
          icon: Icons.place_rounded,
          color: AppColors.primaryBlue,
        ),
      ],
      exitGateA: defaultGateA,
      exitGateB: defaultGateB,
    );
  }

  // Helper untuk direct route
  if ((isFromMrt && isToMrt) || (isFromKrl && isToKrl) || (isFromLrt && isToLrt)) {
    final lineName = isFromMrt
        ? 'MRT Jakarta'
        : (isFromKrl ? 'KRL Commuter Line' : 'LRT Jabodebek');
    final lineColor = isFromMrt
        ? AppColors.lineMRT
        : (isFromKrl ? AppColors.lineBogor : AppColors.lineLRTCibubur);

    final stopsCount = 3;
    final duration = stopsCount * 4;
    final price = 3000 + (stopsCount * 1000);

    return RoutePlan(
      from: fromNorm,
      to: toNorm,
      travelTime: duration,
      fare: price,
      stops: stopsCount,
      serviceInfo: l10n.lineNoTransit(lineName),
      hasTransit: false,
      steps: [
        RoutePlanStep(
          text: l10n.boardLineFrom(lineName, fromNorm),
          durationText: l10n.departureTime,
          detailNote: l10n.platformDirection(1, toNorm),
          icon: Icons.directions_transit_filled_rounded,
          color: lineColor,
          isHeader: true,
        ),
        RoutePlanStep(
          text: l10n.directTripTo(toNorm, stopsCount),
          durationText: l10n.estDuration(duration),
          detailNote: l10n.skipStops(stopsCount),
          icon: Icons.directions_railway_rounded,
          color: lineColor,
        ),
        RoutePlanStep(
          text: l10n.arriveAtDest(toNorm),
          durationText: l10n.totalDuration(duration),
          detailNote: l10n.elevatedStation,
          icon: Icons.place_rounded,
          color: AppColors.statusGreen,
          isDestination: true,
        ),
      ],
      exitGateA: l10n.gateA(defaultGateA),
      exitGateB: l10n.gateB(defaultGateB),
    );
  }

  // Kasus Transit di Setiabudi
  int stops1 = 2;
  int stops2 = 3;
  int dur1 = stops1 * 4; // 8 mnt
  int dur2 = stops2 * 4; // 12 mnt
  int transitDur = 5;    // 5 mnt
  int totalTime = dur1 + dur2 + transitDur; // 25 mnt

  String line1 = isFromMrt ? 'MRT Jakarta' : (isFromKrl ? 'KRL Commuter Line' : 'LRT Jabodebek (Jalur Hijau)');
  Color color1 = isFromMrt ? AppColors.lineMRT : (isFromKrl ? AppColors.lineBogor : AppColors.lineLRTBekasi);

  String line2 = isToMrt ? 'MRT Jakarta' : (isToKrl ? 'KRL Commuter Line' : 'LRT Jabodebek (Lin Cibubur)');
  Color color2 = isToMrt ? AppColors.lineMRT : (isToKrl ? AppColors.lineBogor : AppColors.lineLRTCibubur);

  return RoutePlan(
    from: fromNorm,
    to: toNorm,
    travelTime: totalTime,
    fare: 10000,
    stops: stops1 + stops2,
    serviceInfo: l10n.oneTransitAt('Setiabudi'),
    hasTransit: true,
    steps: [
      RoutePlanStep(
        text: l10n.boardLineFrom(line1, fromNorm),
        durationText: l10n.departureTime,
        detailNote: l10n.platformDirection(1, 'Setiabudi'),
        icon: Icons.directions_transit_filled_rounded,
        color: color1,
        isHeader: true,
      ),
      RoutePlanStep(
        text: l10n.alightAt('Setiabudi', stops1),
        durationText: l10n.estDuration(dur1),
        detailNote: l10n.prepareTransitAt('Setiabudi'),
        icon: Icons.directions_subway_rounded,
        color: color1,
      ),
      RoutePlanStep(
        text: l10n.transitToLine('Setiabudi', line2),
        durationText: l10n.estDuration(transitDur),
        detailNote: l10n.transitPlatform1To2,
        icon: Icons.swap_horizontal_circle_rounded,
        color: AppColors.statusAmber,
        isTransit: true,
      ),
      RoutePlanStep(
        text: l10n.boardLineTo(line2, toNorm, stops2),
        durationText: l10n.estDuration(dur2),
        detailNote: l10n.nextTrainAtPlatform(3, 2),
        icon: Icons.train_rounded,
        color: color2,
      ),
      RoutePlanStep(
        text: l10n.arriveAtDest(toNorm),
        durationText: l10n.totalDuration(totalTime),
        detailNote: l10n.elevatedStation,
        icon: Icons.place_rounded,
        color: AppColors.statusGreen,
        isDestination: true,
      ),
    ],
    exitGateA: l10n.gateA(l10n.mainAccessGate),
    exitGateB: l10n.gateB(l10n.dropOffGate),
  );
}

/// Halaman Rute Tercepat (Redesigned Solid Clean Version)
class RouteResultPage extends StatefulWidget {
  const RouteResultPage({super.key});

  @override
  State<RouteResultPage> createState() => _RouteResultPageState();
}

class _RouteResultPageState extends State<RouteResultPage> {
  String _selectedFilter = 'Tercepat';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uri = GoRouterState.of(context).uri;
    final from = uri.queryParameters['from'] ?? 'Halim';
    final to = uri.queryParameters['to'] ?? 'Taman Mini';

    final route = _calculateRoute(from, to, l10n);

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
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Modern Custom Header Bar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/?selected=$from'),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.routeGuideTitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        route.from,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      child: Icon(
                                        Icons.east_rounded,
                                        size: 16,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        route.to,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryBlue,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ── A11Y Badge Button ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.a11yYellow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.accessibility_new_rounded,
                                  size: 14,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'A11Y',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Filter Segment Chips ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildFilterChip(l10n.fastest)),
                            Expanded(child: _buildFilterChip(l10n.minTransit)),
                            Expanded(child: _buildFilterChip(l10n.accessible)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Simple & Clean Journey Summary ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.travelEstimate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '${route.travelTime}',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.minutesOnly,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.stopsAndService(route.stops, route.serviceInfo),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.travelFare,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedFare,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Live Realtime ETA Card ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LiveEtaCard(
                        etaText: l10n.nextTrainAtPlatform(3, 1),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Timeline Detail Rute Perjalanan ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTimelineWidget(route),
                    ),

                    const SizedBox(height: 16),

                    // ── Informasi Pintu Keluar Stasiun Tujuan ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildExitGateWidget(route),
                    ),

                    const SizedBox(height: 20),

                    // ── Hero Action Button: Beli Tiket ──
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
                          icon: const Icon(
                            Icons.confirmation_num_rounded,
                            size: 22,
                          ),
                          label: Text(
                            l10n.buyTicketDirect(formattedFare),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Secondary Action Buttons ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.readRouteToast(route.from, route.to, route.travelTime),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                size: 18,
                              ),
                              label: Text(
                                l10n.readRouteBtn,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/'),
                              icon: const Icon(
                                Icons.map_rounded,
                                size: 18,
                              ),
                              label: Text(
                                l10n.viewOnMapBtn,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Accessibility Announcement Banner ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.a11yBannerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.a11yYellow,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              color: AppColors.a11yBannerText,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.a11yAudioRoute(route.from, route.to, route.travelTime, route.stops),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.a11yBannerText,
                                  fontWeight: FontWeight.w600,
                                ),
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
            const AppBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    IconData? iconData;
    final l10n = AppLocalizations.of(context)!;
    if (label == l10n.fastest) iconData = Icons.bolt_rounded;
    if (label == l10n.minTransit) iconData = Icons.sync_alt_rounded;
    if (label == l10n.accessible) iconData = Icons.accessible_rounded;

    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconData != null) ...[
              Icon(
                iconData,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun Widget Timeline Perjalanan Modern dengan Estimasi Menit per Langkah
  Widget _buildTimelineWidget(RoutePlan route) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.routeTimeline,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...route.steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isLast = idx == route.steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Connector Line & Icon Node
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: step.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: step.color,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          step.icon,
                          size: 16,
                          color: step.color,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 3,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: step.color.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Step Detail Box with Duration Badge
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (step.isHeader || step.isDestination || step.isTransit)
                            ? step.color.withValues(alpha: 0.05)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (step.isHeader || step.isDestination || step.isTransit)
                              ? step.color.withValues(alpha: 0.25)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  step.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: (step.isHeader || step.isDestination || step.isTransit)
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // ── Badge Estimasi Menit / Waktu ──
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: step.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  step.durationText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: step.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (step.detailNote.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              step.detailNote,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Widget Informasi Pintu Keluar (Exit Gate) Stasiun Tujuan
  Widget _buildExitGateWidget(RoutePlan route) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.door_sliding_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.exitGateInfo(route.to),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    route.exitGateA,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.statusGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.statusGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  color: AppColors.statusGreen,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    route.exitGateB,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card Live ETA Realtime
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.statusGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: AppColors.statusGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.statusGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.nextTrainLive,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.statusGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  etaText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
