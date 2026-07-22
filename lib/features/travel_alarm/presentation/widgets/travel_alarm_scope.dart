import 'package:flutter/widgets.dart';

import '../controllers/travel_alarm_controller.dart';

class TravelAlarmScope extends InheritedNotifier<TravelAlarmController> {
  const TravelAlarmScope({
    super.key,
    required TravelAlarmController controller,
    required super.child,
  }) : super(notifier: controller);

  static TravelAlarmController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TravelAlarmScope>();
    assert(scope != null, 'TravelAlarmScope is missing above this context.');
    return scope!.notifier!;
  }
}
