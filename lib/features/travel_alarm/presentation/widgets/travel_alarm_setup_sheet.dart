import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TravelAlarmSelection {
  const TravelAlarmSelection({
    required this.departure,
    required this.destination,
  });

  final bool departure;
  final bool destination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelAlarmSelection &&
          other.departure == departure &&
          other.destination == destination;

  @override
  int get hashCode => Object.hash(departure, destination);
}

Future<TravelAlarmSelection?> showTravelAlarmSetupSheet(
  BuildContext context, {
  required String from,
  required String to,
}) {
  return showModalBottomSheet<TravelAlarmSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _TravelAlarmSetupSheet(from: from, to: to),
  );
}

class _TravelAlarmSetupSheet extends StatefulWidget {
  const _TravelAlarmSetupSheet({required this.from, required this.to});

  final String from;
  final String to;

  @override
  State<_TravelAlarmSetupSheet> createState() => _TravelAlarmSetupSheetState();
}

class _TravelAlarmSetupSheetState extends State<_TravelAlarmSetupSheet> {
  bool _departureEnabled = true;
  bool _destinationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.alarm_add_rounded,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Aktifkan pengingat perjalanan?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.from} ke ${widget.to}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            _AlarmToggleRow(
              semanticsLabel: 'Pengingat kereta datang',
              title: 'Kereta datang',
              description: 'Ingatkan 5 menit dan 1 menit sebelumnya',
              icon: Icons.train_rounded,
              switchKey: const Key('departure-alarm-toggle'),
              value: _departureEnabled,
              onChanged: (value) => setState(() => _departureEnabled = value),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _AlarmToggleRow(
              semanticsLabel: 'Pengingat turun atau transit',
              title: 'Turun atau transit',
              description: 'Ingatkan 1 stasiun sebelum tujuan',
              icon: Icons.transfer_within_a_station_rounded,
              switchKey: const Key('destination-alarm-toggle'),
              value: _destinationEnabled,
              onChanged: (value) => setState(() => _destinationEnabled = value),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pengingat ini merupakan simulasi dan aktif selama aplikasi dibuka.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _departureEnabled || _destinationEnabled
                    ? () => Navigator.pop(
                        context,
                        TravelAlarmSelection(
                          departure: _departureEnabled,
                          destination: _destinationEnabled,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.alarm_on_rounded),
                label: const Text('Aktifkan alarm'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textOnPrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Lewati'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlarmToggleRow extends StatelessWidget {
  const _AlarmToggleRow({
    required this.semanticsLabel,
    required this.title,
    required this.description,
    required this.icon,
    required this.switchKey,
    required this.value,
    required this.onChanged,
  });

  final String semanticsLabel;
  final String title;
  final String description;
  final IconData icon;
  final Key switchKey;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticsLabel,
      value: value ? 'aktif' : 'nonaktif',
      toggled: value,
      onTap: () => onChanged(!value),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  key: switchKey,
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
