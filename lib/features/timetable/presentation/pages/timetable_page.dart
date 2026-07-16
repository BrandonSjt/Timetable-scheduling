import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../domain/entities/train_schedule.dart';
import '../controllers/timetable_controller.dart';
import '../widgets/schedule_card.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final TimetableController _controller = TimetableController();
  late final List<TrainSchedule> _schedules;
  
  // State Filter
  String _searchQuery = '';
  String _selectedStationFilter = 'Semua Stasiun';
  String _selectedTypeFilter = 'Semua'; // 'Semua', 'KRL', 'LRT', 'MRT'
  bool _isWeekendFilter = false; // false = Hari Kerja (Weekday), true = Akhir Pekan (Weekend)

  // Daftar Stasiun yang tersedia di peta skematik
  final List<String> _stations = [
    'Semua Stasiun',
    'Setiabudi',
    'Cawang',
    'Manggarai',
    'Tanah Abang',
    'Halim',
  ];

  // Daftar Jenis Kereta
  final List<String> _trainTypes = [
    'Semua',
    'KRL',
    'LRT',
    'MRT',
  ];

  @override
  void initState() {
    super.initState();
    _schedules = _controller.loadSchedules();
  }

  Color _getTrainColor(String type) {
    switch (type.toUpperCase()) {
      case 'LRT':
        return AppColors.badgeLRT;
      case 'KRL':
        return AppColors.badgeKRL;
      case 'MRT':
        return const Color(0xFF005A9C);
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Terapkan semua filter secara bertahap
    final filteredSchedules = _schedules.where((schedule) {
      // 1. Filter Hari Kerja / Akhir Pekan (KakaoMetro style)
      if (schedule.isWeekend != _isWeekendFilter) return false;

      // 2. Filter Stasiun Keberangkatan
      if (_selectedStationFilter != 'Semua Stasiun' &&
          schedule.stationName.toLowerCase() != _selectedStationFilter.toLowerCase()) {
        return false;
      }

      // 3. Filter Jenis Kereta (KRL/LRT/MRT)
      if (_selectedTypeFilter != 'Semua' &&
          schedule.trainType.toUpperCase() != _selectedTypeFilter.toUpperCase()) {
        return false;
      }

      // 4. Filter Pencarian Text (Cari Rute atau Nama Kereta)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = schedule.trainName.toLowerCase().contains(query);
        final matchRoute = schedule.route.toLowerCase().contains(query);
        return matchName || matchRoute;
      }

      return true;
    }).toList();

    // Urutkan jadwal berdasarkan waktu keberangkatan
    filteredSchedules.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Section ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul dan Segmented Control Weekday/Weekend (KakaoMetro Style)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadwal Kereta',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'KRL · LRT · MRT Jakarta',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      // KakaoMetro Style Day Selector (Capsule Switch)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isWeekendFilter = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_isWeekendFilter ? AppColors.primaryBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Hari Kerja',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: !_isWeekendFilter ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isWeekendFilter = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isWeekendFilter ? AppColors.primaryBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Akhir Pekan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _isWeekendFilter ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textHint, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Cari stasiun tujuan atau nomor kereta...',
                              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Icon(Icons.clear, color: AppColors.textHint, size: 16),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),

            // ── Filter Horizontal Row ──
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // Filter 1: Pilih Jenis Kereta (Semua, KRL, LRT, MRT)
                  SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _trainTypes.length,
                      itemBuilder: (context, index) {
                        final type = _trainTypes[index];
                        final isSelected = _selectedTypeFilter == type;
                        final typeColor = _getTrainColor(type);

                        return GestureDetector(
                          onTap: () => setState(() => _selectedTypeFilter = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? typeColor.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? typeColor : AppColors.cardBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? typeColor : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Filter 2: Pilih Stasiun Asal
                  SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _stations.length,
                      itemBuilder: (context, index) {
                        final station = _stations[index];
                        final isSelected = _selectedStationFilter == station;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedStationFilter = station),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                station,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),

            // ── Schedule List ──
            Expanded(
              child: filteredSchedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.train_outlined,
                            size: 48,
                            color: AppColors.textHint.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Jadwal tidak ditemukan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cobalah mengubah filter stasiun atau hari.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSchedules.length,
                      itemBuilder: (context, index) {
                        return ScheduleCard(schedule: filteredSchedules[index]);
                      },
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
