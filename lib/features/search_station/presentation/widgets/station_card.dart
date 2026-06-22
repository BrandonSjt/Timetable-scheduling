import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget card stasiun dengan ikon dot, nama, jalur, dan info tambahan.
class StationCard extends StatelessWidget {
  final String name;
  final String lineInfo;
  final String statusText;
  final Color statusColor;

  const StationCard({
    super.key,
    required this.name,
    required this.lineInfo,
    required this.statusText,
    this.statusColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // ── Dot icon ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.circle,
                size: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Nama & jalur ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lineInfo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Status / info ──
          Flexible(
            child: Text(
              statusText,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chip untuk filter layanan: Semua, LRT, KRL, Aksesibel
class ServiceFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const ServiceFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
