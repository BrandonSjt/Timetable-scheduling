import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_detail_scaffold.dart';

/// Detail tiket aktif yang tersimpan pada perangkat pengguna.
class ActiveTicketDetailPage extends StatelessWidget {
  const ActiveTicketDetailPage({super.key});

  void _shareTicket(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Kode tiket aktif siap dibagikan.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: 'Detail tiket aktif',
      subtitle: 'KRL-2407-0812',
      fallbackRoute: '/riwayat-tiket',
      children: [
        const _ActiveTicketSummary(),
        const SizedBox(height: 16),
        const _TicketCodeCard(),
        const SizedBox(height: 16),
        const _TicketInformationCard(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareTicket(context),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Bagikan kode'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
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
              child: FilledButton.icon(
                onPressed: () => context.push('/pusat-bantuan'),
                icon: const Icon(Icons.support_agent_rounded, size: 19),
                label: const Text('Butuh bantuan'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android_rounded,
              color: AppColors.textHint,
              size: 16,
            ),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                'Data tiket hanya tersimpan di perangkat ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActiveTicketSummary extends StatelessWidget {
  const _ActiveTicketSummary();

  @override
  Widget build(BuildContext context) {
    return _TicketCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.train_rounded,
                  color: AppColors.primaryBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KRL Commuter Line',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Hari ini, 08:12 WIB',
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
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Bogor → Jakarta Kota',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCodeCard extends StatelessWidget {
  const _TicketCodeCard();

  @override
  Widget build(BuildContext context) {
    return _TicketCard(
      child: Column(
        children: [
          const Text(
            'Kode tiket aktif',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tunjukkan kode ini kepada petugas',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Semantics(
            image: true,
            label: 'Kode tiket aktif KRL-2407-0812',
            child: Container(
              width: 164,
              height: 164,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const CustomPaint(painter: _TicketCodePainter()),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'KRL-2407-0812',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_done_outlined,
                color: Color(0xFF16A34A),
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                'Tersimpan offline',
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketInformationCard extends StatelessWidget {
  const _TicketInformationCard();

  @override
  Widget build(BuildContext context) {
    return const _TicketCard(
      child: Column(
        children: [
          _InformationRow(label: 'Stasiun asal', value: 'Bogor'),
          SizedBox(height: 14),
          _InformationRow(label: 'Tujuan', value: 'Jakarta Kota'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.cardBorder),
          ),
          _InformationRow(label: 'Perkiraan tiba', value: '09:32 WIB'),
          SizedBox(height: 14),
          _InformationRow(label: 'Jenis tiket', value: 'Tiket aktif'),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final String label;
  final String value;

  const _InformationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Widget child;

  const _TicketCard({required this.child});

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

class _TicketCodePainter extends CustomPainter {
  const _TicketCodePainter();

  static const int _modules = 21;

  bool _isFinderModule(int row, int column, int startRow, int startColumn) {
    final localRow = row - startRow;
    final localColumn = column - startColumn;
    if (localRow < 0 || localRow > 6 || localColumn < 0 || localColumn > 6) {
      return false;
    }
    final border =
        localRow == 0 || localRow == 6 || localColumn == 0 || localColumn == 6;
    final center =
        localRow >= 2 && localRow <= 4 && localColumn >= 2 && localColumn <= 4;
    return border || center;
  }

  bool _isDark(int row, int column) {
    if (_isFinderModule(row, column, 0, 0) ||
        _isFinderModule(row, column, 0, 14) ||
        _isFinderModule(row, column, 14, 0)) {
      return true;
    }
    final inFinderSpace =
        (row < 8 && column < 8) ||
        (row < 8 && column > 12) ||
        (row > 12 && column < 8);
    if (inFinderSpace) return false;
    return ((row * 3 + column * 5 + row * column) % 7) < 3;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final moduleSize = size.shortestSide / _modules;
    final paint = Paint()..color = const Color(0xFF111827);
    for (var row = 0; row < _modules; row++) {
      for (var column = 0; column < _modules; column++) {
        if (!_isDark(row, column)) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            column * moduleSize,
            row * moduleSize,
            moduleSize + 0.2,
            moduleSize + 0.2,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
