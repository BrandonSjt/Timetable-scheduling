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
      _DepartureInfo('MRT', 'Bundaran HI', '3 menit', '1', '5 menit'),
      _DepartureInfo('MRT', 'Lebak Bulus', '5 menit', '2', '24 menit'),
      _DepartureInfo('LRT', 'Dukuh Atas', '4 menit', '3', '3 menit'),
      _DepartureInfo('LRT', 'Cawang', '8 menit', '4', '15 menit'),
    ],
  ),
  'Cawang': _StationInfo(
    name: 'Cawang',
    departures: [
      _DepartureInfo('LRT', 'Dukuh Atas', '4 menit', '1', '18 menit'),
      _DepartureInfo('LRT', 'Jatimulya', '6 menit', '2', '20 menit'),
      _DepartureInfo('LRT', 'Harjamukti', '5 menit', '3', '12 menit'),
      _DepartureInfo('KRL', 'Manggarai', '7 menit', '4', '8 menit'),
    ],
  ),
  'Manggarai': _StationInfo(
    name: 'Manggarai',
    departures: [
      _DepartureInfo('KRL', 'Jakarta Kota', '5 menit', '10', '10 menit'),
      _DepartureInfo('KRL', 'Bogor', '4 menit', '12', '50 menit'),
      _DepartureInfo('KRL', 'Tanah Abang', '6 menit', '6', '8 menit'),
      _DepartureInfo('KRL', 'Bekasi', '8 menit', '3', '35 menit'),
    ],
  ),
  'Tanah Abang': _StationInfo(
    name: 'Tanah Abang',
    departures: [
      _DepartureInfo('KRL', 'Rangkasbitung', '5 menit', '5', '75 menit'),
      _DepartureInfo('KRL', 'Manggarai', '4 menit', '2', '8 menit'),
      _DepartureInfo('KRL', 'Kampung Bandan', '7 menit', '3', '15 menit'),
    ],
  ),
  'Halim': _StationInfo(
    name: 'Halim',
    departures: [
      _DepartureInfo('LRT', 'Dukuh Atas', '7 menit', '1', '22 menit'),
      _DepartureInfo('LRT', 'Jatimulya', '6 menit', '2', '15 menit'),
    ],
  ),
  'Bundaran HI': _StationInfo(
    name: 'Bundaran HI',
    departures: [
      _DepartureInfo('MRT', 'Lebak Bulus', '6 menit', '1', '30 menit'),
      _DepartureInfo('MRT', 'Dukuh Atas', '3 menit', '2', '2 menit'),
    ],
  ),
  'Blok M BCA': _StationInfo(
    name: 'Blok M BCA',
    departures: [
      _DepartureInfo('MRT', 'Bundaran HI', '4 menit', '1', '12 menit'),
      _DepartureInfo('MRT', 'Lebak Bulus', '5 menit', '2', '18 menit'),
    ],
  ),
  'Dukuh Atas': _StationInfo(
    name: 'Dukuh Atas',
    departures: [
      _DepartureInfo('MRT', 'Bundaran HI', '3 menit', '1', '2 menit'),
      _DepartureInfo('MRT', 'Lebak Bulus', '4 menit', '2', '28 menit'),
      _DepartureInfo('LRT', 'Cawang', '5 menit', '3', '18 menit'),
      _DepartureInfo('LRT', 'Jatimulya', '6 menit', '4', '38 menit'),
    ],
  ),
  'Jatinegara': _StationInfo(
    name: 'Jatinegara',
    departures: [
      _DepartureInfo('KRL', 'Cikarang', '6 menit', '1', '40 menit'),
      _DepartureInfo('KRL', 'Kampung Bandan', '5 menit', '2', '20 menit'),
      _DepartureInfo('KRL', 'Manggarai', '7 menit', '3', '10 menit'),
    ],
  ),
  'Jakarta Kota': _StationInfo(
    name: 'Jakarta Kota',
    departures: [
      _DepartureInfo('KRL', 'Bogor', '5 menit', '1', '60 menit'),
      _DepartureInfo('KRL', 'Tanjung Priok', '8 menit', '2', '15 menit'),
    ],
  ),
  'Kampung Bandan': _StationInfo(
    name: 'Kampung Bandan',
    departures: [
      _DepartureInfo('KRL', 'Jakarta Kota', '4 menit', '1', '5 menit'),
      _DepartureInfo('KRL', 'Tanah Abang', '6 menit', '2', '15 menit'),
      _DepartureInfo('KRL', 'Pasar Senen', '5 menit', '3', '10 menit'),
    ],
  ),
  'Bekasi': _StationInfo(
    name: 'Bekasi',
    departures: [
      _DepartureInfo('KRL', 'Jatinegara', '6 menit', '1', '18 menit'),
      _DepartureInfo('KRL', 'Cikarang', '7 menit', '2', '20 menit'),
    ],
  ),
  'Lebak Bulus': _StationInfo(
    name: 'Lebak Bulus',
    departures: [
      _DepartureInfo('MRT', 'Bundaran HI', '5 menit', '1', '30 menit'),
    ],
  ),
  'Duri': _StationInfo(
    name: 'Duri',
    departures: [
      _DepartureInfo('KRL', 'Tangerang', '6 menit', '1', '25 menit'),
      _DepartureInfo('KRL', 'Tanah Abang', '5 menit', '2', '8 menit'),
    ],
  ),
  'Citayam': _StationInfo(
    name: 'Citayam',
    departures: [
      _DepartureInfo('KRL', 'Bogor', '4 menit', '1', '15 menit'),
      _DepartureInfo('KRL', 'Nambo', '6 menit', '2', '20 menit'),
      _DepartureInfo('KRL', 'Jakarta Kota', '5 menit', '3', '45 menit'),
    ],
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

    final currentStation = selectedParam ?? _selectedStation;

    final info = currentStation != null
        ? (_stationInfoMap[currentStation] ??
            _StationInfo(
              name: currentStation,
              departures: const [
                _DepartureInfo('KRL', 'Arah Tujuan 1', '5 menit', '1', '15 menit'),
                _DepartureInfo('KRL', 'Arah Tujuan 2', '12 menit', '2', '45 menit'),
              ],
            ))
        : null;

    return PopScope(
      canPop: currentStation == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentStation != null) {
          setState(() {
            _selectedStation = null;
          });
          final fromQuery = _fromStation != null ? '?from=$_fromStation' : '';
          context.go('/$fromQuery');
        }
      },
      child: Scaffold(
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
              child: Row(
                children: [
                  Expanded(
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
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // TODO: Tampilkan opsi filter (misal: bottom sheet filter)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter map akan segera hadir!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Icon(
                        Icons.menu_rounded, // Menggunakan icon hamburger menu (burger icon)
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                                          horizontal: 16,
                                          vertical: 10,
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
      ),
    );
  }
}

class _NextTrainBoard extends StatefulWidget {
  final String stationName;
  final List<_DepartureInfo> departures;
  final ValueChanged<_DepartureInfo> onDepartureTap;

  const _NextTrainBoard({
    required this.stationName,
    required this.departures,
    required this.onDepartureTap,
  });

  @override
  State<_NextTrainBoard> createState() => _NextTrainBoardState();
}

class _NextTrainBoardState extends State<_NextTrainBoard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final int maxVisible = 2;
    final bool hasMore = widget.departures.length > maxVisible;
    final visibleDepartures = _isExpanded || !hasMore
        ? widget.departures
        : widget.departures.take(maxVisible).toList();

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
                  'Kereta berikutnya dari ${widget.stationName}',
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
          ...visibleDepartures.map((departure) {
            final isLastVisible = departure == visibleDepartures.last;
            return _NextTrainRow(
              departure: departure,
              showDivider: !isLastVisible,
              onTap: () => widget.onDepartureTap(departure),
            );
          }),
          if (hasMore) ...[
            if (!_isExpanded) const SizedBox(height: 4),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    _isExpanded
                        ? 'Tutup'
                        : 'Tampilkan Semua (${widget.departures.length})',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
