import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_detail_scaffold.dart';

class _HelpTopic {
  final String title;
  final String subtitle;

  const _HelpTopic(this.title, this.subtitle);
}

const _helpTopics = [
  _HelpTopic('Cara membeli tiket lokal', 'Panduan untuk KRL dan LRT'),
  _HelpTopic('Jadwal atau ETA tidak sesuai', 'Kirim laporan dari detail rute'),
  _HelpTopic('Masalah pembayaran', 'Cek status transaksi terakhir'),
];

/// Pusat bantuan mode tamu dengan pencarian dan pintasan dukungan.
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  String _query = '';

  List<_HelpTopic> get _visibleTopics {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _helpTopics;
    return _helpTopics
        .where(
          (topic) =>
              topic.title.toLowerCase().contains(query) ||
              topic.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final topics = _visibleTopics;

    return ProfileDetailScaffold(
      title: 'Pusat Bantuan',
      subtitle: 'Kontak petugas dan laporan',
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari bantuan, stasiun, atau tiket',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Aksi cepat',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pilih bantuan yang paling sering dipakai',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _QuickHelpAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat petugas',
                iconColor: AppColors.primaryBlue,
                iconBackground: const Color(0xFFEFF6FF),
                onTap: () => _showMessage('Menghubungkan ke chat petugas.'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickHelpAction(
                icon: Icons.report_outlined,
                label: 'Lapor info salah',
                iconColor: AppColors.accentOrange,
                iconBackground: const Color(0xFFFFF1E8),
                onTap: () => _showMessage('Form laporan info salah dibuka.'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Text(
          'Topik bantuan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        if (topics.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Text(
              'Topik bantuan tidak ditemukan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          )
        else
          for (var index = 0; index < topics.length; index++) ...[
            _HelpTopicTile(
              topic: topics[index],
              onTap: () => _showMessage('${topics[index].title} dibuka.'),
            ),
            if (index != topics.length - 1) const SizedBox(height: 10),
          ],
        const SizedBox(height: 24),
        Material(
          color: const Color(0xFFFFF7ED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFFED7AA)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showMessage('Menghubungi KAI melalui 121.'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hubungi KAI: 121',
                      style: TextStyle(
                        color: AppColors.accentOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.accentOrange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickHelpAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const _QuickHelpAction({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpTopicTile extends StatelessWidget {
  final _HelpTopic topic;
  final VoidCallback onTap;

  const _HelpTopicTile({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
