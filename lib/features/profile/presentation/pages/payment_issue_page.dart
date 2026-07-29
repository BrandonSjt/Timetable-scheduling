import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _PaymentIssue {
  deductedBalance(
    label: 'Saldo terpotong',
    title: 'Saldo Terpotong',
    status: 'Diproses',
    transactionDetail: 'Rp 8.000 terpotong, tiket belum aktif',
    advice:
        'Cek Riwayat tiket setelah 2 menit.\nKirim bantuan jika status belum berubah.',
    actionLabel: 'Laporkan saldo terpotong',
  ),
  missingTicket(
    label: 'Tiket belum muncul',
    title: 'Tiket Belum Muncul',
    status: 'Berhasil',
    transactionDetail: 'Pembayaran berhasil, tiket belum tampil',
    advice:
        'Muat ulang halaman Tiket Saya.\nJika tetap kosong, kirim kode transaksi.',
    actionLabel: 'Laporkan tiket belum muncul',
  ),
  refund(
    label: 'Refund',
    title: 'Refund',
    status: 'Diajukan',
    transactionDetail: 'Pengembalian dana untuk tiket',
    advice:
        'Refund mengikuti status transaksi terakhir.\nSimpan kode tiket sampai proses selesai.',
    actionLabel: 'Ajukan refund',
  ),
  paymentMethod(
    label: 'Metode bayar',
    title: 'Metode Bayar',
    status: 'Gagal',
    transactionDetail: 'Metode pembayaran tidak dapat digunakan',
    advice: 'Coba metode pembayaran lain.\nLaporkan jika semua metode gagal.',
    actionLabel: 'Laporkan metode bayar',
  );

  final String label;
  final String title;
  final String status;
  final String transactionDetail;
  final String advice;
  final String actionLabel;

  const _PaymentIssue({
    required this.label,
    required this.title,
    required this.status,
    required this.transactionDetail,
    required this.advice,
    required this.actionLabel,
  });
}

class PaymentIssuePage extends StatefulWidget {
  const PaymentIssuePage({super.key});

  @override
  State<PaymentIssuePage> createState() => _PaymentIssuePageState();
}

class _PaymentIssuePageState extends State<PaymentIssuePage> {
  _PaymentIssue _issue = _PaymentIssue.deductedBalance;

  void _selectIssue(String label) {
    setState(() {
      _issue = _PaymentIssue.values.firstWhere((issue) => issue.label == label);
    });
  }

  Color get _statusColor {
    return switch (_issue) {
      _PaymentIssue.missingTicket => AppColors.statusGreen,
      _PaymentIssue.paymentMethod => AppColors.statusRed,
      _ => AppColors.accentOrange,
    };
  }

  Color get _statusBackground {
    return switch (_issue) {
      _PaymentIssue.missingTicket => const Color(0xFFE8F8F0),
      _PaymentIssue.paymentMethod => const Color(0xFFFEECEC),
      _ => const Color(0xFFFFF1E8),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: _issue.title,
      subtitle: 'Cek status transaksi',
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.primaryBlue,
          iconBackground: const Color(0xFFEAF2FF),
          title: 'Masalah pembayaran',
          status: 'Kendala aktif: ${_issue.label}',
          description: 'Saran dan tindakan mengikuti kendala yang dipilih.',
        ),
        const SizedBox(height: 28),
        HelpFieldCard(
          label: 'Transaksi terakhir',
          value: 'KRL-2407-0812',
          supportingText: _issue.transactionDetail,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _statusBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _issue.status,
              style: TextStyle(
                color: _statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const HelpSectionHeading(title: 'Pilih kendala'),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: _PaymentIssue.values.map((issue) => issue.label).toList(),
          selected: _issue.label,
          onSelected: _selectIssue,
          columns: 2,
          accentColor: AppColors.primaryBlue,
          selectedBackground: const Color(0xFFEAF2FF),
        ),
        const SizedBox(height: 28),
        HelpFieldCard(label: 'Saran cepat', value: _issue.advice),
        const SizedBox(height: 22),
        HelpPrimaryButton(
          label: _issue.actionLabel,
          color: AppColors.primaryBlue,
          onPressed: () => showHelpMessage(
            context,
            'Bantuan ${_issue.label.toLowerCase()} berhasil disiapkan.',
          ),
        ),
      ],
    );
  }
}
