import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/station_card.dart';

class _StationItem {
  final String name;
  final String lineInfo;
  final String statusText;
  final Color statusColor;
  final bool isLrt;
  final bool isKrl;
  final bool isAccessible;

  const _StationItem({
    required this.name,
    required this.lineInfo,
    required this.statusText,
    required this.statusColor,
    required this.isLrt,
    required this.isKrl,
    required this.isAccessible,
  });
}

const List<_StationItem> _allStations = [
  _StationItem(
    name: 'Setiabudi',
    lineInfo: 'LRT Jabodebek (Jalur Hijau)',
    statusText: 'Lift tersedia · 3 menit',
    statusColor: AppColors.statusGreen,
    isLrt: true,
    isKrl: false,
    isAccessible: true,
  ),
  _StationItem(
    name: 'Manggarai',
    lineInfo: 'KRL Jabodetabek (Jalur Oranye)',
    statusText: 'Kepadatan sedang · 6 menit',
    statusColor: AppColors.statusAmber,
    isLrt: false,
    isKrl: true,
    isAccessible: true,
  ),
  _StationItem(
    name: 'Cawang',
    lineInfo: 'LRT Jabodebek & KRL Jabodetabek',
    statusText: 'Transit aksesibel · 8 menit',
    statusColor: AppColors.primaryBlue,
    isLrt: true,
    isKrl: true,
    isAccessible: true,
  ),
  _StationItem(
    name: 'Tanah Abang',
    lineInfo: 'KRL Jabodetabek (Jalur Oranye)',
    statusText: 'Peron ramai · 5 menit',
    statusColor: AppColors.statusAmber,
    isLrt: false,
    isKrl: true,
    isAccessible: false,
  ),
  _StationItem(
    name: 'Halim',
    lineInfo: 'LRT Jabodebek (Jalur Hijau) & KCIC',
    statusText: 'Lift & Ramp tersedia',
    statusColor: AppColors.statusGreen,
    isLrt: true,
    isKrl: false,
    isAccessible: true,
  ),
];

/// Halaman Cari Stasiun (Screen 2 di Figma)
/// Menampilkan search bar, filter layanan, daftar stasiun,
/// dan mendukung pemilihan stasiun secara fungsional.
class SearchStationPage extends StatefulWidget {
  const SearchStationPage({super.key});

  @override
  State<SearchStationPage> createState() => _SearchStationPageState();
}

class _SearchStationPageState extends State<SearchStationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Membaca action dan stasiun asal dari query parameters
    final uri = GoRouterState.of(context).uri;
    final action = uri.queryParameters['action'];
    final fromStation = uri.queryParameters['from'];
    final isSelectingDestination = action == 'select_destination';

    // Logika penyaringan stasiun
    final filteredStations = _allStations.where((station) {
      // 1. Filter stasiun asal agar tidak bisa dipilih sebagai stasiun tujuan
      if (isSelectingDestination && station.name == fromStation) {
        return false;
      }

      // 2. Filter berdasarkan ketikan pencarian
      final matchesSearch = station.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            station.lineInfo.toLowerCase().contains(_searchQuery.toLowerCase());

      // 3. Filter berdasarkan tab layanan
      final matchesFilter = _selectedFilter == 'Semua' ||
                            (_selectedFilter == 'LRT' && station.isLrt) ||
                            (_selectedFilter == 'KRL' && station.isKrl) ||
                            (_selectedFilter == 'Aksesibel' && station.isAccessible);

      return matchesSearch && matchesFilter;
    }).toList();

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
                          Expanded(
                            child: Text(
                              isSelectingDestination
                                  ? 'Pilih stasiun tujuan'
                                  : 'Cari stasiun',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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

                    if (isSelectingDestination && fromStation != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                        child: Text(
                          'Mulai perjalanan dari: $fromStation',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                    // ── Search Bar ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Ketik nama stasiun, jalur, atau area',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
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
                          _buildFilterChip('Semua'),
                          const SizedBox(width: 8),
                          _buildFilterChip('LRT'),
                          const SizedBox(width: 8),
                          _buildFilterChip('KRL'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Aksesibel'),
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

                    // ── Daftar Stasiun Dinamis ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: filteredStations.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'Stasiun tidak ditemukan',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          : Column(
                              children: filteredStations.map((station) {
                                return StationCard(
                                  name: station.name,
                                  lineInfo: station.lineInfo,
                                  statusText: station.statusText,
                                  statusColor: station.statusColor,
                                  onTap: () {
                                    if (isSelectingDestination && fromStation != null) {
                                      // Rute Tercepat
                                      context.go('/rute?from=$fromStation&to=${station.name}');
                                    } else {
                                      // Pilih di Peta Utama
                                      context.go('/?selected=${station.name}');
                                    }
                                  },
                                );
                              }).toList(),
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
            AppBottomNavBar(currentIndex: isSelectingDestination ? 0 : 1),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ServiceFilterChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }
}
