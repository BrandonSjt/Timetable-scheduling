import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/map_widgets.dart';

class _DepartureInfo {
  final String lineType;
  final String destination;
  final String duration;
  final String platform;
  final String travelDuration;
  const _DepartureInfo(
    this.lineType,
    this.destination,
    this.duration, [
    this.platform = '1',
    this.travelDuration = '',
  ]);
}

class _StationInfo {
  final String name;
  final List<_DepartureInfo> departures;

  const _StationInfo({required this.name, required this.departures});
}

const Map<String, _StationInfo> _stationInfoMap = {
  'Setiabudi': _StationInfo(
    name: 'Setiabudi',
    departures: [
      _DepartureInfo('KRL', 'Manggarai', '3 menit', '1', '7 menit'),
      _DepartureInfo('MRT', 'Bundaran HI', '5 menit', '2', '5 menit'),
      _DepartureInfo('LRT', 'Cawang', '8 menit', '3', '4 menit'),
    ],
  ),
  'Cawang': _StationInfo(
    name: 'Cawang',
    departures: [_DepartureInfo('LRT', 'Setiabudi', '4 menit', '1', '5 menit')],
  ),
  'Manggarai': _StationInfo(
    name: 'Manggarai',
    departures: [
      _DepartureInfo('KRL', 'Tanah Abang', '5 menit', '2', '6 menit'),
      _DepartureInfo('KRL', 'Setiabudi', '3 menit', '3', '7 menit'),
    ],
  ),
  'Tanah Abang': _StationInfo(
    name: 'Tanah Abang',
    departures: [_DepartureInfo('KRL', 'Manggarai', '4 menit', '1', '6 menit')],
  ),
  'Halim': _StationInfo(
    name: 'Halim',
    departures: [_DepartureInfo('LRT', 'Setiabudi', '7 menit', '2', '8 menit')],
  ),
  'Bundaran HI': _StationInfo(
    name: 'Bundaran HI',
    departures: [_DepartureInfo('MRT', 'Setiabudi', '6 menit', '1', '5 menit')],
  ),
  'Blok M': _StationInfo(
    name: 'Blok M',
    departures: [
      _DepartureInfo('MRT', 'Setiabudi', '4 menit', '2', '10 menit'),
    ],
  ),
};

/// Model data untuk stasiun sekitar/terdekat
class _NearbyStation {
  final String name;
  final String distance;
  final List<String> lines;

  const _NearbyStation({
    required this.name,
    required this.distance,
    required this.lines,
  });
}

/// Pemetaan stasiun terdekat & sekitar berdasarkan stasiun terpilih
const Map<String, List<_NearbyStation>> _nearbyStationsMap = {
  'Setiabudi': [
    _NearbyStation(name: 'Manggarai', distance: '1.8 km', lines: ['KRL']),
    _NearbyStation(name: 'Cawang', distance: '3.1 km', lines: ['LRT']),
    _NearbyStation(name: 'Bundaran HI', distance: '1.5 km', lines: ['MRT']),
    _NearbyStation(name: 'Blok M', distance: '4.5 km', lines: ['MRT']),
  ],
  'Cawang': [
    _NearbyStation(name: 'Setiabudi', distance: '3.1 km', lines: ['LRT']),
    _NearbyStation(name: 'Halim', distance: '1.2 km', lines: ['LRT']),
  ],
  'Manggarai': [
    _NearbyStation(name: 'Setiabudi', distance: '1.8 km', lines: ['KRL']),
    _NearbyStation(name: 'Tanah Abang', distance: '2.5 km', lines: ['KRL']),
  ],
  'Tanah Abang': [
    _NearbyStation(name: 'Manggarai', distance: '2.5 km', lines: ['KRL']),
  ],
  'Halim': [
    _NearbyStation(name: 'Cawang', distance: '1.2 km', lines: ['LRT']),
  ],
  'Bundaran HI': [
    _NearbyStation(name: 'Setiabudi', distance: '1.5 km', lines: ['MRT']),
  ],
  'Blok M': [
    _NearbyStation(name: 'Setiabudi', distance: '4.5 km', lines: ['MRT']),
  ],
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
  String? _selectedStation;
  String? _fromStation;

  void _onStationSelected(String stationName) {
    setState(() {
      _selectedStation = stationName;
    });
    // Update URL query parameter to keep everything in sync
    final fromQuery = _fromStation != null ? '&from=$_fromStation' : '';
    context.go('/?selected=$stationName$fromQuery');
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final selectedParam = uri.queryParameters['selected'];
    final fromParam = uri.queryParameters['from'];

    // Jika parameter URL dibersihkan, sinkronkan state lokal ke null agar pop-up tertutup
    if (selectedParam == null && _selectedStation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedStation = null;
          });
        }
      });
    }

    // Sync state if returned from search with fromParam
    if (fromParam != null && _fromStation != fromParam) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _fromStation = fromParam);
      });
    }

    final currentStation =
        (selectedParam != null && _stationInfoMap.containsKey(selectedParam))
        ? selectedParam
        : _selectedStation;

    final info = currentStation != null
        ? _stationInfoMap[currentStation]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header fixed: Search Bar + Filter Chips ──
            const SizedBox(height: 16),

            // ── Top Banner (Dari) ──
            if (_fromStation != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mulai dari: $_fromStation',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _fromStation = null);
                        context.go('/');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  final fromQuery = _fromStation != null
                      ? '?from=$_fromStation'
                      : '';
                  context.go('/cari-stasiun$fromQuery');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.textHint),
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
            const SizedBox(height: 8),

            // ── Peta Skematik (di luar ScrollView agar gesture tidak konflik) ──
            Expanded(
              child: Stack(
                children: [
                  // Peta mengisi seluruh area tengah
                  Positioned.fill(
                    child: MapView(
                      showColors: true,
                      selectedStation: currentStation,
                      fromStation:
                          _fromStation, // Pass the fromStation to highlight it
                      onStationSelected: _onStationSelected,
                    ),
                  ),

                  // ── Panel Info Stasiun (muncul dari bawah saat stasiun diklik) ──
                  if (info != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag Handle Pill removed based on user feedback
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlueLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Stasiun Terpilih',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      // Jika user ingin menutup panel, kita clear selected station
                                      // tapi biarkan fromStation (bila ada) tetap menyala.
                                      // _selectedStation akan ter-clear saat onTap rute go('/')
                                      // Kita panggil context.go('/') untuk update URL & trigger perubahan
                                    });
                                    context.go('/');
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.swap_vert_rounded,
                                          color: AppColors.primaryBlue,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          info.name,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _fromStation = currentStation;
                                          _selectedStation = null;
                                        });
                                        context.go('/?from=$currentStation');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.surface,
                                        foregroundColor: AppColors.primaryBlue,
                                        side: const BorderSide(
                                          color: AppColors.primaryBlue,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text(
                                        'Dari',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_fromStation != null) {
                                          context.go(
                                            '/rute?from=$_fromStation&to=$currentStation',
                                          );
                                        } else {
                                          // Opsional: beritahu user untuk set 'Dari' dulu
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Pilih stasiun asal (Dari) terlebih dahulu!',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text(
                                        'Ke',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            const SizedBox(height: 16),
                            const Divider(color: AppColors.cardBorder),
                            const SizedBox(height: 12),

                            _NextTrainBoard(
                              stationName: info.name,
                              departures: info.departures,
                              onDepartureTap: (dep) {
                                final uri = Uri(
                                  path: '/departure-detail',
                                  queryParameters: {
                                    'lineType': dep.lineType,
                                    'destination': dep.destination,
                                    'duration': dep.duration,
                                    'platform': dep.platform,
                                  },
                                );
                                context.push(uri.toString());
                              },
                            ),

                            // ── Stasiun Terdekat & Sekitar ──
                            if (_nearbyStationsMap.containsKey(
                                  currentStation,
                                ) &&
                                _nearbyStationsMap[currentStation]!
                                    .isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Stasiun Sekitar',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _nearbyStationsMap[currentStation]!.map((
                                    nearby,
                                  ) {
                                    return Container(
                                      width: 150,
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.cardBorder,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            nearby.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_rounded,
                                                size: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                nearby.distance,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: nearby.lines.map((
                                                  line,
                                                ) {
                                                  final color = line == 'KRL'
                                                      ? AppColors.badgeKRL
                                                      : (line == 'MRT'
                                                            ? AppColors.badgeMRT
                                                            : AppColors
                                                                  .badgeLRT);
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 2,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: color.withValues(
                                                        alpha: 0.15,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      line,
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: color,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
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

class _NextTrainBoard extends StatelessWidget {
  final String stationName;
  final List<_DepartureInfo> departures;
  final ValueChanged<_DepartureInfo> onDepartureTap;

  const _NextTrainBoard({
    required this.stationName,
    required this.departures,
    required this.onDepartureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.statusGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kereta berikutnya dari $stationName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...departures.map((departure) {
            final isLast = departure == departures.last;
            return _NextTrainRow(
              departure: departure,
              showDivider: !isLast,
              onTap: () => onDepartureTap(departure),
            );
          }),
        ],
      ),
    );
  }
}

class _NextTrainRow extends StatelessWidget {
  final _DepartureInfo departure;
  final bool showDivider;
  final VoidCallback onTap;

  const _NextTrainRow({
    required this.departure,
    required this.showDivider,
    required this.onTap,
  });

  Color get _badgeColor {
    if (departure.lineType == 'KRL') {
      return AppColors.badgeKRL;
    }
    if (departure.lineType == 'MRT') {
      return AppColors.badgeMRT;
    }
    return AppColors.badgeLRT;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _badgeColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    departure.lineType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        departure.destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (departure.travelDuration.isNotEmpty) ...[
                        Text(
                          'Perjalanan ${departure.travelDuration}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Peron ${departure.platform}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Tujuan ${departure.destination}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Datang ${departure.duration} lagi',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'di stasiun',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, color: AppColors.cardBorder),
        ],
      ),
    );
  }
}
