import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
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

  @override
  void initState() {
    super.initState();
    _schedules = _controller.loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Jadwal keberangkatan hari ini',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Fondasi clean architecture ringan: presentation memanggil controller, controller memakai use case, lalu repository mengambil data lokal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final schedule in _schedules) ScheduleCard(schedule: schedule),
        ],
      ),
    );
  }
}
