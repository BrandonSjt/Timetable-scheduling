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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _schedules = _controller.loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    // Saring jadwal berdasarkan nama kereta atau rute jika ada pencarian
    final filteredSchedules = _schedules.where((schedule) {
      final query = _searchQuery.toLowerCase();
      return schedule.trainName.toLowerCase().contains(query) ||
          schedule.route.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Section ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jadwal Keberangkatan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jadwal keberangkatan KRL & LRT hari ini',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar untuk memfilter jadwal
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textHint, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Cari kereta atau stasiun tujuan...',
                              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                            child: const Icon(Icons.clear, color: AppColors.textHint, size: 18),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),

            // ── List Schedule ──
            Expanded(
              child: filteredSchedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.train_outlined, size: 48, color: AppColors.textHint.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'Jadwal tidak ditemukan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
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
