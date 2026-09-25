import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/assistant/presentation/controllers/assistant_controller.dart';

import 'helpers/fake_assistant_speech.dart';

void main() {
  test('starts ready and unsupported wake word never activates', () {
    final controller = AssistantController(
      recognizer: FakeAssistantSpeechRecognizer(),
      speechService: FakeAssistantPlayback(),
    );
    addTearDown(controller.dispose);
    expect(controller.state, AssistantInteractionState.ready);
    controller.toggleWakeWord(true);
    expect(controller.wakeWordEnabled, isFalse);
  });

  test('recoverable error contains a code rather than a fake answer', () {
    final controller = AssistantController(
      recognizer: FakeAssistantSpeechRecognizer(),
      speechService: FakeAssistantPlayback(),
    );
    addTearDown(controller.dispose);
    controller.showError();
    expect(controller.state, AssistantInteractionState.error);
    expect(controller.errorCode, 'VOICE_UNAVAILABLE');
    expect(controller.assistantResponse, isNull);
  });

  test('duplicate start during recognition is ignored', () async {
    final recognizer = FakeAssistantSpeechRecognizer();
    final controller = AssistantController(
      recognizer: recognizer,
      speechService: FakeAssistantPlayback(),
    );
    addTearDown(controller.dispose);
    await controller.startConversation();
    await controller.startConversation();
    expect(recognizer.listenCalls, 1);
  });
}
