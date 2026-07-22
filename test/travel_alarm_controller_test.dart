import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/travel_alarm/presentation/controllers/travel_alarm_controller.dart';

void main() {
  test('new purchase starts with both alarms unconfirmed', () {
    final controller = TravelAlarmController();

    controller.completePurchase(from: 'Setiabudi', to: 'Manggarai');

    expect(controller.state.hasActiveTicket, isTrue);
    expect(controller.state.departureAlarmEnabled, isFalse);
    expect(controller.state.destinationAlarmEnabled, isFalse);
    expect(controller.state.minutesUntilTrain, 5);
    expect(controller.state.stationsUntilDestination, 1);
  });

  test('selected alarm categories can be activated independently', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai');

    controller.configureAlarms(departure: true, destination: false);

    expect(controller.state.departureAlarmEnabled, isTrue);
    expect(controller.state.destinationAlarmEnabled, isFalse);
    expect(controller.state.hasAnyAlarm, isTrue);
  });

  test('destination and all alarms can be disabled safely', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
      ..configureAlarms(departure: true, destination: true);

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

    expect(controller.nextAlarmDescription, 'Kereta datang 5 menit lagi');

    controller.advanceDepartureDemo();
    expect(controller.nextAlarmDescription, 'Kereta datang 1 menit lagi');

    controller.disableDepartureAlarm();
    expect(
      controller.nextAlarmDescription,
      'Turun di Manggarai, 1 stasiun lagi',
    );
  });

  test('repeated alarm operations do not emit duplicate changes', () {
    final controller = TravelAlarmController();
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
