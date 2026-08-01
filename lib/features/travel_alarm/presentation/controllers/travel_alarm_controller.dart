import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/travel_alarm_state.dart';

class TravelAlarmController extends ChangeNotifier {
  TravelAlarmController({
    this.departureUrgentDelay = const Duration(seconds: 8),
    this.destinationWarningDelay = const Duration(seconds: 14),
  });

  final Duration departureUrgentDelay;
  final Duration destinationWarningDelay;

  TravelAlarmState state = const TravelAlarmState();
  final ValueNotifier<TravelAlarmReminder?> reminder = ValueNotifier(null);
  Timer? _departureTimer;
  Timer? _destinationTimer;
  int _nextReminderId = 0;

  String get nextAlarmDescription {
    if (state.departureAlarmEnabled) {
      return 'Kereta datang ${state.minutesUntilTrain} menit lagi';
    }
    if (state.destinationAlarmEnabled && state.activeTrip != null) {
      return destinationDescription;
    }
    return 'Tidak ada alarm aktif';
  }

  String get destinationDescription {
    final trip = state.activeTrip;
    final action = trip?.transferStation == null
        ? 'Turun di ${trip?.to ?? 'tujuan'}'
        : 'Transit di ${trip!.transferStation}';
    return '$action, ${state.stationsUntilDestination} stasiun lagi';
  }

  void completePurchase({
    required String from,
    required String to,
    String? transferStation,
  }) {
    _cancelTimers();
    _replaceState(
      TravelAlarmState(
        activeTrip: ActiveTrip(
          from: from,
          to: to,
          transferStation: transferStation,
        ),
      ),
    );
  }

  void configureAlarms({required bool departure, required bool destination}) {
    if (!state.hasActiveTicket) return;
    final departureWasEnabled = state.departureAlarmEnabled;
    final destinationWasEnabled = state.destinationAlarmEnabled;

    _replaceState(
      state.copyWith(
        departureAlarmEnabled: departure,
        destinationAlarmEnabled: destination,
      ),
    );

    if (departure && !departureWasEnabled) {
      _departureTimer?.cancel();
      _departureTimer = Timer(departureUrgentDelay, advanceDepartureDemo);
    } else if (!departure) {
      _departureTimer?.cancel();
      _departureTimer = null;
    }

    if (destination && !destinationWasEnabled) {
      _destinationTimer?.cancel();
      _destinationTimer = Timer(
        destinationWarningDelay,
        advanceDestinationDemo,
      );
    } else if (!destination) {
      _destinationTimer?.cancel();
      _destinationTimer = null;
    }
  }

  void disableDepartureAlarm() {
    if (!state.departureAlarmEnabled) return;
    _departureTimer?.cancel();
    _departureTimer = null;
    _replaceState(state.copyWith(departureAlarmEnabled: false));
  }

  void disableDestinationAlarm() {
    if (!state.destinationAlarmEnabled) return;
    _destinationTimer?.cancel();
    _destinationTimer = null;
    _replaceState(state.copyWith(destinationAlarmEnabled: false));
  }

  void cancelAllAlarms() {
    if (!state.hasAnyAlarm) return;
    _cancelTimers();
    _replaceState(
      state.copyWith(
        departureAlarmEnabled: false,
        destinationAlarmEnabled: false,
      ),
    );
  }

  void advanceDepartureDemo() {
    _departureTimer?.cancel();
    _departureTimer = null;
    if (!state.departureAlarmEnabled) return;
    _replaceState(state.copyWith(minutesUntilTrain: 1));
    _emitReminder('Kereta datang 1 menit lagi');
  }

  void advanceDestinationDemo() {
    _destinationTimer?.cancel();
    _destinationTimer = null;
    if (!state.destinationAlarmEnabled) return;
    _replaceState(state.copyWith(stationsUntilDestination: 1));
    _emitReminder(destinationDescription);
  }

  void _emitReminder(String message) {
    reminder.value = TravelAlarmReminder(
      id: ++_nextReminderId,
      message: message,
    );
  }

  void _cancelTimers() {
    _departureTimer?.cancel();
    _destinationTimer?.cancel();
    _departureTimer = null;
    _destinationTimer = null;
  }

  void _replaceState(TravelAlarmState value) {
    if (state == value) return;
    state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimers();
    reminder.dispose();
    super.dispose();
  }
}
