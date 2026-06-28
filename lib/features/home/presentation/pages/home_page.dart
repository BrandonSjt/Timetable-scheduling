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
    _NearbyStation(name: 'Cawang', distance: '3.1 km', lines: ['LRT', 'KRL']),
    _NearbyStation(name: 'Tanah Abang', distance: '4.2 km', lines: ['KRL']),
  ],
  'Cawang': [
    _NearbyStation(name: 'Halim', distance: '1.2 km', lines: ['LRT']),
    _NearbyStation(name: 'Setiabudi', distance: '3.1 km', lines: ['LRT']),
    _NearbyStation(name: 'Manggarai', distance: '4.8 km', lines: ['KRL']),
  ],
  'Manggarai': [
    _NearbyStation(name: 'Setiabudi', distance: '1.8 km', lines: ['LRT']),
    _NearbyStation(name: 'Tanah Abang', distance: '2.5 km', lines: ['KRL']),
    _NearbyStation(name: 'Cawang', distance: '4.8 km', lines: ['LRT', 'KRL']),
  ],
  'Tanah Abang': [
    _NearbyStation(name: 'Manggarai', distance: '2.5 km', lines: ['KRL']),
    _NearbyStation(name: 'Setiabudi', distance: '4.2 km', lines: ['LRT']),
  ],
  'Halim': [
    _NearbyStation(name: 'Cawang', distance: '1.2 km', lines: ['LRT', 'KRL']),
    _NearbyStation(name: 'Setiabudi', distance: '4.3 km', lines: ['LRT']),
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

    final currentStation = (selectedParam != null && _stationInfoMap.containsKey(selectedParam))
        ? selectedParam
        : _selectedStation;

    final info = currentStation != null ? _stationInfoMap[currentStation] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header fixed: Search Bar + Filter Chips ──
            const SizedBox(height: 16),
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
                      onStationSelected: _onStationSelected,
                    ),
                  ),

                  // ── A11Y Banner (tampil saat belum ada stasiun diklik) ──
                  if (info == null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Container(
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.train_rounded,
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
                            const SizedBox(height: 12),

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

                            // ── Section: Stasiun Terdekat & Sekitar ──
                            if (_nearbyStationsMap.containsKey(currentStation)) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Stasiun Terdekat & Sekitar',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 68,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _nearbyStationsMap[currentStation]!.length,
                                  itemBuilder: (context, index) {
                                    final nearby = _nearbyStationsMap[currentStation]![index];
                                    return GestureDetector(
                                      onTap: () => _onStationSelected(nearby.name),
                                      child: Container(
                                        width: 150,
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.cardBorder),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 10,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  nearby.distance,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Row(
                                                  children: nearby.lines.map((line) {
                                                    final color = line == 'LRT' ? AppColors.badgeLRT : AppColors.badgeKRL;
                                                    return Container(
                                                      margin: const EdgeInsets.only(left: 2),
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: color.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        line,
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.w800,
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
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

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
