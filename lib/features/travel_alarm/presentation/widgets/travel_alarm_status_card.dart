import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/travel_alarm_state.dart';

class TravelAlarmStatusCard extends StatelessWidget {
  const TravelAlarmStatusCard({
    super.key,
    required this.message,
    required this.state,
    required this.onViewTicket,
    required this.onCancelAlarm,
    this.canCancelAlarm,
  });

  final String message;
  final TravelAlarmState state;
  final VoidCallback onViewTicket;
  final VoidCallback onCancelAlarm;
  final bool? canCancelAlarm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trip = state.activeTrip;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.alarm_on_rounded,
                color: AppColors.primaryBlue,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (trip != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.routeFromTo(trip.from, trip.to),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _AlarmStatusLine(
            isActive: state.departureAlarmEnabled,
            label: state.departureAlarmEnabled
                ? l10n.alarmDepartureActive
                : l10n.alarmDepartureInactive,
          ),
          const SizedBox(height: 6),
          _AlarmStatusLine(
            isActive: state.destinationAlarmEnabled,
            label: state.destinationAlarmEnabled
                ? l10n.alarmDestinationActive
                : l10n.alarmDestinationInactive,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: onViewTicket,
                icon: const Icon(Icons.confirmation_num_outlined, size: 18),
                label: Text(l10n.viewTicketBtn),
              ),
              if (canCancelAlarm ?? state.hasAnyAlarm)
                TextButton.icon(
                  onPressed: onCancelAlarm,
                  icon: const Icon(Icons.alarm_off_rounded, size: 18),
                  label: Text(l10n.cancelAlarmBtn),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlarmStatusLine extends StatelessWidget {
  const _AlarmStatusLine({required this.isActive, required this.label});

  final bool isActive;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle_rounded : Icons.cancel_outlined,
          color: isActive ? AppColors.statusGreen : AppColors.textSecondary,
          size: 17,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
