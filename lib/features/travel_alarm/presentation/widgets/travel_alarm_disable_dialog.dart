import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

Future<bool> showTravelAlarmDisableDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          icon: const Icon(Icons.alarm_off_rounded, color: AppColors.statusRed),
          title: const Text('Matikan alarm perjalanan?'),
          content: const Text(
            'Pengingat kereta datang dan pengingat turun atau transit akan dinonaktifkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Kembali'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.statusRed,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Matikan alarm'),
            ),
          ],
        ),
      ) ??
      false;
}
