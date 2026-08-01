import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/travel_alarm/presentation/controllers/travel_alarm_controller.dart';

void main() {
  test('new purchase starts with both alarms unconfirmed', () {
    final controller = TravelAlarmController();
    addTearDown(controller.dispose);

    controller.completePurchase(from: 'Setiabudi', to: 'Manggarai');

    expect(controller.state.hasActiveTicket, isTrue);
    expect(controller.state.departureAlarmEnabled, isFalse);
    expect(controller.state.destinationAlarmEnabled, isFalse);
    expect(controller.state.minutesUntilTrain, 5);
    expect(controller.state.stationsUntilDestination, 2);
  });

  test('selected alarm categories can be activated independently', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai');
    addTearDown(controller.dispose);

    controller.configureAlarms(departure: true, destination: false);

    expect(controller.state.departureAlarmEnabled, isTrue);
    expect(controller.state.destinationAlarmEnabled, isFalse);
    expect(controller.state.hasAnyAlarm, isTrue);
  });

  test('destination and all alarms can be disabled safely', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
      ..configureAlarms(departure: true, destination: true);
    addTearDown(controller.dispose);

    controller.disableDestinationAlarm();
    expect(controller.state.departureAlarmEnabled, isTrue);
    expect(controller.state.destinationAlarmEnabled, isFalse);

    controller.cancelAllAlarms();
    expect(controller.state.hasAnyAlarm, isFalse);
  });

  test('next alarm describes departure then destination state', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
      ..configureAlarms(departure: true, destination: true);
    addTearDown(controller.dispose);

    expect(controller.nextAlarmDescription, 'Kereta datang 5 menit lagi');

    controller.advanceDepartureDemo();
    expect(controller.nextAlarmDescription, 'Kereta datang 1 menit lagi');

    controller.disableDepartureAlarm();
    controller.advanceDestinationDemo();
    expect(
      controller.nextAlarmDescription,
      'Turun di Manggarai, 1 stasiun lagi',
    );
  });

  test('active alarms advance to urgent in-app reminders', () async {
    final controller =
        TravelAlarmController(
            departureUrgentDelay: const Duration(milliseconds: 1),
            destinationWarningDelay: const Duration(milliseconds: 2),
          )
          ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
          ..configureAlarms(departure: true, destination: true);
    addTearDown(controller.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(controller.state.minutesUntilTrain, 1);
    expect(controller.state.stationsUntilDestination, 1);
    expect(
      controller.reminder.value?.message,
      'Turun di Manggarai, 1 stasiun lagi',
    );
  });

  test('transfer trip produces a transfer reminder', () {
    final controller = TravelAlarmController()
      ..completePurchase(
        from: 'Halim',
        to: 'Bundaran HI',
        transferStation: 'Setiabudi',
      )
      ..configureAlarms(departure: false, destination: true);
    addTearDown(controller.dispose);

    controller.advanceDestinationDemo();

    expect(controller.state.activeTrip?.transferStation, 'Setiabudi');
    expect(
      controller.destinationDescription,
      'Transit di Setiabudi, 1 stasiun lagi',
    );
    expect(
      controller.reminder.value?.message,
      'Transit di Setiabudi, 1 stasiun lagi',
    );
  });

  test('cancelling alarms stops pending reminder transitions', () async {
    final controller =
        TravelAlarmController(
            departureUrgentDelay: const Duration(milliseconds: 1),
            destinationWarningDelay: const Duration(milliseconds: 2),
          )
          ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
          ..configureAlarms(departure: true, destination: true)
          ..cancelAllAlarms();
    addTearDown(controller.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(controller.state.minutesUntilTrain, 5);
    expect(controller.state.stationsUntilDestination, 2);
  });

  test('repeated alarm operations do not emit duplicate changes', () {
    final controller = TravelAlarmController();
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.configureAlarms(departure: true, destination: true);
    expect(notifications, 0);

    controller.completePurchase(from: 'Setiabudi', to: 'Manggarai');
    controller.configureAlarms(departure: true, destination: true);
    controller.configureAlarms(departure: true, destination: true);

    expect(notifications, 2);
  });
}
