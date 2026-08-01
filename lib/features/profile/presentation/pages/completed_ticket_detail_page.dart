import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_detail_scaffold.dart';

/// Detail perjalanan yang telah selesai dan tersimpan di riwayat perangkat.
class CompletedTicketDetailPage extends StatelessWidget {
  const CompletedTicketDetailPage({super.key});

  void _downloadReceipt(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Bukti perjalanan berhasil disiapkan.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: 'Detail tiket selesai',
      subtitle: 'LRT-0707-1518',
      fallbackRoute: '/riwayat-tiket',
      children: [
        const _CompletedTicketSummary(),
        const SizedBox(height: 16),
        const _JourneySummaryCard(),
        const SizedBox(height: 16),
        const _JourneyInformationCard(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _downloadReceipt(context),
                icon: const Icon(Icons.download_rounded, size: 19),
                label: const Text('Unduh bukti'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.cardBorder),
                  backgroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/pusat-bantuan'),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('Laporkan masalah'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentOrange,
                  side: const BorderSide(color: Color(0xFFFED7AA)),
                  backgroundColor: const Color(0xFFFFF7ED),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Detail selesai tetap tersimpan di riwayat lokal.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _CompletedTicketSummary extends StatelessWidget {
  const _CompletedTicketSummary();

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0E4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.train_rounded,
                  color: AppColors.accentOrange,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LRT Jabodebek',
                      style: TextStyle(
                        color: AppColors.accentOrange,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Dukuh Atas → Harjamukti',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Selasa, 7 Jul 2026',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneySummaryCard extends StatelessWidget {
  const _JourneySummaryCard();

  @override
  Widget build(BuildContext context) {
    return const _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan perjalanan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TimeInformation(label: 'Berangkat', value: '15:18 WIB'),
              ),
              Expanded(
                child: _TimeInformation(label: 'Tiba', value: '16:02 WIB'),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.cardBorder),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Durasi 44 menit',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                'Perjalanan selesai',
                style: TextStyle(
                  color: Color(0xFF17A871),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeInformation extends StatelessWidget {
  final String label;
  final String value;

  const _TimeInformation({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _JourneyInformationCard extends StatelessWidget {
  const _JourneyInformationCard();

  @override
  Widget build(BuildContext context) {
    return const _DetailCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabelValue(label: 'Stasiun asal', value: 'Dukuh Atas'),
              ),
              SizedBox(width: 18),
              Expanded(
                child: _LabelValue(
                  label: 'Stasiun tujuan',
                  value: 'Harjamukti',
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.cardBorder),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabelValue(
                  label: 'Kode perjalanan',
                  value: 'LRT-0707-1518',
                  compact: true,
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: _LabelValue(
                  label: 'Jenis tiket',
                  value: 'Tiket lokal',
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool compact;

  const _LabelValue({
    required this.label,
    required this.value,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: compact ? 13 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
