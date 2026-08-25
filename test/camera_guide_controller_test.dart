import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/assistant/presentation/controllers/camera_guide_controller.dart';

void main() {
  testWidgets(
    'does not stop while the camera permission flow is still loading',
    (tester) async {
      final controller = CameraGuideController();

      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump();

      expect(controller.state, CameraGuideState.loading);
    },
  );
}
