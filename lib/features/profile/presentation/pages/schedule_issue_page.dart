import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _ScheduleIssue {
  late(
    label: 'ETA terlambat',
    title: 'ETA Terlambat',
    activeLabel: 'ETA terlambat',
    route: 'Bogor → Jakarta Kota',
    routeDetail: 'ETA aplikasi: 09:32 WIB',
    note: 'Papan stasiun menunjukkan 09:40 WIB.',
    guidance: 'Koreksi membantu akurasi ETA rute ini.',
    actionLabel: 'Kirim koreksi ETA',
  ),
  missingTrain(
    label: 'Kereta hilang',
    title: 'Kereta Hilang',
    activeLabel: 'Kereta tidak muncul',
    route: 'Bekasi → Manggarai',
    routeDetail: 'Kereta terdekat tidak tampil',
    note: 'Kereta terlihat di stasiun, tetapi tidak ada di aplikasi.',
    guidance: 'Laporan melengkapi data keberangkatan.',
    actionLabel: 'Laporkan kereta hilang',
  ),
  changedSchedule(
    label: 'Jadwal berubah',
    title: 'Jadwal Berubah',
    activeLabel: 'Jadwal berubah',
    route: 'Dukuh Atas → Harjamukti',
    routeDetail: 'Jadwal aplikasi: 15:18 WIB',
    note: 'Jadwal di stasiun berubah menjadi 15:30 WIB.',
    guidance: 'Laporan membantu sinkronisasi jadwal.',
    actionLabel: 'Kirim perubahan jadwal',
  ),
  differentPlatform(
    label: 'Peron berbeda',
    title: 'Peron Berbeda',
    activeLabel: 'Peron berbeda',
    route: 'Bogor → Jakarta Kota',
    routeDetail: 'Peron aplikasi: Peron 2',
    note: 'Petugas mengarahkan penumpang ke Peron 4.',
    guidance: 'Laporan membantu memperbaiki info peron.',
    actionLabel: 'Kirim koreksi peron',
  );

  final String label;
  final String title;
  final String activeLabel;
  final String route;
  final String routeDetail;
  final String note;
  final String guidance;
  final String actionLabel;

  const _ScheduleIssue({
    required this.label,
    required this.title,
    required this.activeLabel,
    required this.route,
    required this.routeDetail,
    required this.note,
    required this.guidance,
    required this.actionLabel,
  });
}

class ScheduleIssuePage extends StatefulWidget {
  const ScheduleIssuePage({super.key});

  @override
  State<ScheduleIssuePage> createState() => _ScheduleIssuePageState();
}

class _ScheduleIssuePageState extends State<ScheduleIssuePage> {
  _ScheduleIssue _issue = _ScheduleIssue.late;

  void _selectIssue(String label) {
    setState(() {
      _issue = _ScheduleIssue.values.firstWhere(
        (issue) => issue.label == label,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: _issue.title,
      subtitle: 'Laporkan ketidaksesuaian',
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.accentOrange,
          iconBackground: const Color(0xFFFFF1E8),
          title: 'Jadwal & ETA',
          status: 'Masalah aktif: ${_issue.activeLabel}',
          description: 'Detail laporan mengikuti masalah yang dipilih.',
        ),
        const SizedBox(height: 28),
        HelpFieldCard(
          label: 'Rute dipantau',
          value: _issue.route,
          supportingText: _issue.routeDetail,
        ),
        const SizedBox(height: 28),
        const HelpSectionHeading(title: 'Masalah yang terjadi'),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: _ScheduleIssue.values.map((issue) => issue.label).toList(),
          selected: _issue.label,
          onSelected: _selectIssue,
          columns: 2,
          accentColor: AppColors.accentOrange,
          selectedBackground: const Color(0xFFFFF1E8),
        ),
        const SizedBox(height: 28),
        HelpFieldCard(label: 'Catatan', value: _issue.note),
        const SizedBox(height: 18),
        HelpSurfaceCard(
          color: const Color(0xFFE8F8F0),
          borderColor: const Color(0xFFB7E9D2),
          child: Text(
            _issue.guidance,
            style: const TextStyle(
              color: Color(0xFF079669),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 22),
        HelpPrimaryButton(
          label: _issue.actionLabel,
          color: AppColors.accentOrange,
          onPressed: () => showHelpMessage(
            context,
            'Koreksi ${_issue.activeLabel.toLowerCase()} berhasil disiapkan.',
          ),
        ),
      ],
    );
  }
}
