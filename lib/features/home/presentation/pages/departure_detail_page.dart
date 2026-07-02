import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DepartureDetailPage extends StatelessWidget {
  final String lineType;
  final String destination;
  final String duration;
  final String platform;

  const DepartureDetailPage({
    super.key,
    required this.lineType,
    required this.destination,
    required this.duration,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor = AppColors.badgeLRT;
    if (lineType == 'KRL') badgeColor = AppColors.badgeKRL;
    if (lineType == 'MRT') badgeColor = AppColors.badgeMRT;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Keberangkatan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            lineType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tujuan Akhir',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              destination,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tiba Dalam', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            duration,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Nomor Peron', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Peron $platform',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: badgeColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Informasi Status ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.a11yBannerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.a11yYellow.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.a11yBannerText, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Kereta beroperasi normal. Fasilitas prioritas tersedia di gerbong 3 dan 4.',
                      style: TextStyle(fontSize: 13, color: AppColors.a11yBannerText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Stasiun Berikutnya ──
            const Text(
              'Stasiun Berikutnya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildNextStationTile('Dukuh Atas', '2 Menit', 'Peron 1', isFirst: true),
                  const Divider(color: AppColors.cardBorder, height: 1, indent: 48),
                  _buildNextStationTile('Sudirman', '5 Menit', 'Peron 2'),
                  const Divider(color: AppColors.cardBorder, height: 1, indent: 48),
                  _buildNextStationTile('Manggarai (Transit)', '8 Menit', 'Peron 5', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Promo Banner ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PROMO',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Diskon 50% Tiket Kereta Antarkota',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Beli tiket mudik sekarang dan dapatkan potongan harga spesial menggunakan KAI Pay.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStationTile(String stationName, String time, String platformInfo, {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 2,
                height: 8,
                color: isFirst ? Colors.transparent : AppColors.cardBorder,
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isLast ? AppColors.accentOrange : AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              Container(
                width: 2,
                height: 24,
                color: isLast ? Colors.transparent : AppColors.cardBorder,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$time • Tiba di $platformInfo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
