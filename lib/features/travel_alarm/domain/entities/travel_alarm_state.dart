import 'package:flutter/foundation.dart';

@immutable
class ActiveTrip {
  const ActiveTrip({
    required this.from,
    required this.to,
    this.transferStation,
  });

  final String from;
  final String to;
  final String? transferStation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveTrip &&
          other.from == from &&
          other.to == to &&
          other.transferStation == transferStation;

  @override
  int get hashCode => Object.hash(from, to, transferStation);
}

@immutable
class TravelAlarmReminder {
  const TravelAlarmReminder({required this.id, required this.message});

  final int id;
  final String message;
}

@immutable
class TravelAlarmState {
  const TravelAlarmState({
    this.activeTrip,
    this.departureAlarmEnabled = false,
    this.destinationAlarmEnabled = false,
    this.minutesUntilTrain = 5,
    this.stationsUntilDestination = 2,
  });

  final ActiveTrip? activeTrip;
  final bool departureAlarmEnabled;
  final bool destinationAlarmEnabled;
  final int minutesUntilTrain;
  final int stationsUntilDestination;

  bool get hasActiveTicket => activeTrip != null;
  bool get hasAnyAlarm => departureAlarmEnabled || destinationAlarmEnabled;

  TravelAlarmState copyWith({
    ActiveTrip? activeTrip,
    bool? departureAlarmEnabled,
    bool? destinationAlarmEnabled,
    int? minutesUntilTrain,
    int? stationsUntilDestination,
  }) {
    return TravelAlarmState(
      activeTrip: activeTrip ?? this.activeTrip,
      departureAlarmEnabled:
          departureAlarmEnabled ?? this.departureAlarmEnabled,
      destinationAlarmEnabled:
          destinationAlarmEnabled ?? this.destinationAlarmEnabled,
      minutesUntilTrain: minutesUntilTrain ?? this.minutesUntilTrain,
      stationsUntilDestination:
          stationsUntilDestination ?? this.stationsUntilDestination,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelAlarmState &&
          other.activeTrip == activeTrip &&
          other.departureAlarmEnabled == departureAlarmEnabled &&
          other.destinationAlarmEnabled == destinationAlarmEnabled &&
          other.minutesUntilTrain == minutesUntilTrain &&
          other.stationsUntilDestination == stationsUntilDestination;

  @override
  int get hashCode => Object.hash(
    activeTrip,
    departureAlarmEnabled,
    destinationAlarmEnabled,
    minutesUntilTrain,
    stationsUntilDestination,
  );
}
