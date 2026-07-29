import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _ChatTopic {
  ticket(
    label: 'Tiket',
    title: 'Chat Tiket',
    agent: 'Petugas tiket tersedia',
    waitTime: 'Biasanya membalas dalam 2 menit',
    openingMessage: 'Saya butuh bantuan terkait tiket',
    sharedData: 'Mode tamu, ID tiket, dan rute terakhir',
    actionLabel: 'Mulai chat tiket',
  ),
  schedule(
    label: 'Jadwal',
    title: 'Chat Jadwal',
    agent: 'Petugas jadwal tersedia',
    waitTime: 'Biasanya membalas dalam 3 menit',
    openingMessage: 'Saya butuh bantuan terkait jadwal atau ETA kereta',
    sharedData: 'Rute terakhir, stasiun asal-tujuan, dan waktu perjalanan',
    actionLabel: 'Mulai chat jadwal',
  ),
  payment(
    label: 'Pembayaran',
    title: 'Chat Pembayaran',
    agent: 'Petugas pembayaran tersedia',
    waitTime: 'Biasanya membalas dalam 4 menit',
    openingMessage: 'Saya butuh bantuan terkait pembayaran tiket',
    sharedData: 'Status transaksi terakhir, kode tiket, dan waktu pembayaran',
    actionLabel: 'Mulai chat pembayaran',
  );

  final String label;
  final String title;
  final String agent;
  final String waitTime;
  final String openingMessage;
  final String sharedData;
  final String actionLabel;

  const _ChatTopic({
    required this.label,
    required this.title,
    required this.agent,
    required this.waitTime,
    required this.openingMessage,
    required this.sharedData,
    required this.actionLabel,
  });
}

class HelpChatPage extends StatefulWidget {
  const HelpChatPage({super.key});

  @override
  State<HelpChatPage> createState() => _HelpChatPageState();
}

class _HelpChatPageState extends State<HelpChatPage> {
  _ChatTopic _topic = _ChatTopic.ticket;

  void _selectTopic(String label) {
    setState(() {
      _topic = _ChatTopic.values.firstWhere((topic) => topic.label == label);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: _topic.title,
      subtitle: 'Bantuan langsung',
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.primaryBlue,
          iconBackground: const Color(0xFFEAF2FF),
          title: 'Chat dengan petugas',
          status: 'Topik aktif: ${_topic.label}',
          description: 'Konten chat disesuaikan dengan pilihan Anda.',
        ),
        const SizedBox(height: 28),
        const HelpSectionHeading(
          title: 'Status layanan',
          subtitle: 'Estimasi tunggu saat ini',
        ),
        const SizedBox(height: 16),
        HelpSurfaceCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF17A871),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _topic.agent,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _topic.waitTime,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const HelpSectionHeading(title: 'Pilih topik'),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: _ChatTopic.values.map((topic) => topic.label).toList(),
          selected: _topic.label,
          onSelected: _selectTopic,
          columns: 3,
          accentColor: AppColors.primaryBlue,
          selectedBackground: const Color(0xFFEAF2FF),
        ),
        const SizedBox(height: 22),
        HelpFieldCard(label: 'Pesan awal', value: _topic.openingMessage),
        const SizedBox(height: 14),
        HelpFieldCard(label: 'Data yang dikirim', value: _topic.sharedData),
        const SizedBox(height: 22),
        HelpPrimaryButton(
          label: _topic.actionLabel,
          color: AppColors.primaryBlue,
          onPressed: () => showHelpMessage(
            context,
            'Menghubungkan ke ${_topic.agent.toLowerCase()}.',
          ),
        ),
      ],
    );
  }
}
