import 'package:flutter/widgets.dart';

import '../controllers/auth_controller.dart';

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context, {bool listen = true}) {
    if (!listen) {
      return context.getInheritedWidgetOfExactType<AuthScope>()!.notifier!;
    }
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;
  }
}
