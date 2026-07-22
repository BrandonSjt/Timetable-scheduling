import 'package:flutter/foundation.dart';

import '../../domain/entities/travel_alarm_state.dart';

class TravelAlarmController extends ChangeNotifier {
  TravelAlarmState state = const TravelAlarmState();

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
    final destination = state.activeTrip?.to ?? 'tujuan';
    return 'Turun di $destination, ${state.stationsUntilDestination} stasiun lagi';
  }

  void completePurchase({required String from, required String to}) {
    _replaceState(
      TravelAlarmState(
        activeTrip: ActiveTrip(from: from, to: to),
      ),
    );
  }

  void configureAlarms({required bool departure, required bool destination}) {
    if (!state.hasActiveTicket) return;
    _replaceState(
      state.copyWith(
        departureAlarmEnabled: departure,
        destinationAlarmEnabled: destination,
      ),
    );
  }

  void disableDepartureAlarm() {
    if (!state.departureAlarmEnabled) return;
    _replaceState(state.copyWith(departureAlarmEnabled: false));
  }

  void disableDestinationAlarm() {
    if (!state.destinationAlarmEnabled) return;
    _replaceState(state.copyWith(destinationAlarmEnabled: false));
  }

  void cancelAllAlarms() {
    if (!state.hasAnyAlarm) return;
    _replaceState(
      state.copyWith(
        departureAlarmEnabled: false,
        destinationAlarmEnabled: false,
      ),
    );
  }

  void advanceDepartureDemo() {
    _replaceState(state.copyWith(minutesUntilTrain: 1));
  }

  void advanceDestinationDemo() {
    _replaceState(state.copyWith(stationsUntilDestination: 1));
  }

  void _replaceState(TravelAlarmState value) {
    if (state == value) return;
    state = value;
    notifyListeners();
  }
}
