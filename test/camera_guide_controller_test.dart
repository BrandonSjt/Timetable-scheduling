import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/assistant/presentation/controllers/camera_guide_controller.dart';
import 'package:timetable/features/assistant/presentation/pages/camera_guide_page.dart';

import 'helpers/localized_test_app.dart';

class _TrackingCameraGuideController extends CameraGuideController {
  int restartCalls = 0;
  int announceCalls = 0;

  @override
  Future<void> start() async {}

  @override
  Future<void> restart() async {
    restartCalls += 1;
  }

  @override
  Future<void> announceGuideActive(String message) async {
    announceCalls += 1;
  }

  void activate() {
    state = CameraGuideState.active;
    notifyListeners();
  }
}

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

  testWidgets('restarts after returning from a lifecycle pause', (
    tester,
  ) async {
    final controller = _TrackingCameraGuideController()
      ..state = CameraGuideState.active;

    controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
    await tester.pump();
    expect(controller.state, CameraGuideState.stopped);

    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();

    expect(controller.restartCalls, 1);
  });

  testWidgets('offers to start the guide when the camera is stopped', (
    tester,
  ) async {
    final controller = _TrackingCameraGuideController()
      ..state = CameraGuideState.stopped;

    await tester.pumpWidget(
      MaterialApp(home: CameraGuidePage(controller: controller)),
    );

    expect(find.text('Mulai Pemandu'), findsOneWidget);
    await tester.tap(find.text('Mulai Pemandu'));
    await tester.pump();

    expect(controller.restartCalls, 1);
  });

  testWidgets('auto voice announces once when the camera becomes active', (
    tester,
  ) async {
    final controller = _TrackingCameraGuideController();

    await tester.pumpWidget(
      localizedTestApp(
        home: CameraGuidePage(controller: controller, autoAnnounce: true),
      ),
    );

    controller.activate();
    await tester.pump();
    controller.activate();
    await tester.pump();

    expect(controller.announceCalls, 1);
  });

  testWidgets('default camera access does not force a startup announcement', (
    tester,
  ) async {
    final controller = _TrackingCameraGuideController();

    await tester.pumpWidget(
      localizedTestApp(home: CameraGuidePage(controller: controller)),
    );

    controller.activate();
    await tester.pump();

    expect(controller.announceCalls, 0);
  });
}
