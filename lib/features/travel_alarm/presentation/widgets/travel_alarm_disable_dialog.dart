import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

Future<bool> showTravelAlarmDisableDialog(
  BuildContext context, {
  bool departureEnabled = true,
  bool destinationEnabled = true,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final description = switch ((departureEnabled, destinationEnabled)) {
    (true, true) => l10n.alarmDisableBoth,
    (true, false) => l10n.alarmDisableDeparture,
    (false, true) => l10n.alarmDisableDestination,
    (false, false) => l10n.alarmDisableNone,
  };
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          icon: const Icon(Icons.alarm_off_rounded, color: AppColors.statusRed),
          title: Text(l10n.alarmDisableTitle),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionBack),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.statusRed,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: Text(l10n.alarmDisableAction),
            ),
          ],
        ),
      ) ??
      false;
}
