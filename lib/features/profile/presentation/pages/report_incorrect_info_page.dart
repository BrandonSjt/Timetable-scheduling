import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _ReportType {
  schedule(
    label: 'Jadwal',
    title: 'Lapor Jadwal',
    firstLabel: 'Rute terkait',
    firstValue: 'Bogor → Jakarta Kota',
    secondLabel: 'Lokasi / stasiun',
    secondValue: 'Bogor',
    description: 'ETA di aplikasi berbeda dengan papan informasi stasiun.',
    actionLabel: 'Kirim laporan jadwal',
  ),
  route(
    label: 'Rute',
    title: 'Lapor Rute',
    firstLabel: 'Rute bermasalah',
    firstValue: 'Dukuh Atas → Harjamukti',
    secondLabel: 'Titik rute',
    secondValue: 'Stasiun transit',
    description: 'Rute yang tampil tidak melewati stasiun transit yang benar.',
    actionLabel: 'Kirim laporan rute',
  ),
  station(
    label: 'Stasiun',
    title: 'Lapor Stasiun',
    firstLabel: 'Nama stasiun',
    firstValue: 'Jakarta Kota',
    secondLabel: 'Info yang salah',
    secondValue: 'Peron / fasilitas',
    description: 'Informasi stasiun tidak sesuai dengan kondisi di lokasi.',
    actionLabel: 'Kirim laporan stasiun',
  );

  final String label;
  final String title;
  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;
  final String description;
  final String actionLabel;

  const _ReportType({
    required this.label,
    required this.title,
    required this.firstLabel,
    required this.firstValue,
    required this.secondLabel,
    required this.secondValue,
    required this.description,
    required this.actionLabel,
  });
}

class ReportIncorrectInfoPage extends StatefulWidget {
  const ReportIncorrectInfoPage({super.key});

  @override
  State<ReportIncorrectInfoPage> createState() =>
      _ReportIncorrectInfoPageState();
}

class _ReportIncorrectInfoPageState extends State<ReportIncorrectInfoPage> {
  _ReportType _type = _ReportType.schedule;

  void _selectType(String label) {
    setState(() {
      _type = _ReportType.values.firstWhere((type) => type.label == label);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: _type.title,
      subtitle: 'Koreksi data perjalanan',
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.accentOrange,
          iconBackground: const Color(0xFFFFF1E8),
          title: 'Lapor info salah',
          status: 'Jenis laporan: ${_type.label}',
          description: 'Isian mengikuti jenis laporan yang dipilih.',
        ),
        const SizedBox(height: 28),
        const HelpSectionHeading(title: 'Jenis laporan'),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: _ReportType.values.map((type) => type.label).toList(),
          selected: _type.label,
          onSelected: _selectType,
          columns: 3,
          accentColor: AppColors.accentOrange,
          selectedBackground: const Color(0xFFFFF1E8),
        ),
        const SizedBox(height: 22),
        HelpFieldCard(label: _type.firstLabel, value: _type.firstValue),
        const SizedBox(height: 14),
        HelpFieldCard(label: _type.secondLabel, value: _type.secondValue),
        const SizedBox(height: 14),
        HelpFieldCard(label: 'Deskripsi laporan', value: _type.description),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () => showHelpMessage(
            context,
            'Pilih screenshot dari perangkat untuk dilampirkan.',
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Lampirkan screenshot'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentOrange,
            minimumSize: const Size.fromHeight(52),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: const BorderSide(color: Color(0xFFFDBA74)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        HelpPrimaryButton(
          label: _type.actionLabel,
          color: AppColors.accentOrange,
          onPressed: () => showHelpMessage(
            context,
            'Laporan ${_type.label.toLowerCase()} berhasil disiapkan.',
          ),
        ),
      ],
    );
  }
}
