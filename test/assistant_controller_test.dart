import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/assistant/presentation/controllers/assistant_controller.dart';

void main() {
  test('assistant starts ready and toggles wake-word mode', () {
    final controller = AssistantController();

    expect(controller.state, AssistantInteractionState.ready);
    expect(controller.wakeWordEnabled, isFalse);

    controller.toggleWakeWord(true);

    expect(controller.wakeWordEnabled, isTrue);
    controller.dispose();
  });

  test('assistant completes the local trip-planning conversation', () async {
    final states = <AssistantInteractionState>[];
    final controller = AssistantController(
      listeningDuration: const Duration(milliseconds: 1),
      processingDuration: const Duration(milliseconds: 1),
      speakingDuration: const Duration(milliseconds: 1),
    );
    controller.addListener(() => states.add(controller.state));

    controller.startConversation();

    expect(controller.state, AssistantInteractionState.listening);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(
      states,
      containsAllInOrder([
        AssistantInteractionState.listening,
        AssistantInteractionState.processing,
        AssistantInteractionState.speaking,
        AssistantInteractionState.confirmation,
      ]),
    );
    expect(controller.userTranscript, contains('Manggarai'));
    expect(controller.assistantResponse, contains('Kereta tiba 5 menit lagi'));
    controller.dispose();
  });

  test('cancelling conversation stops pending state changes', () async {
    final controller = AssistantController(
      listeningDuration: const Duration(milliseconds: 20),
    );

    controller.startConversation();
    controller.cancelConversation();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(controller.state, AssistantInteractionState.ready);
    expect(controller.userTranscript, isNull);
    expect(controller.assistantResponse, isNull);
    controller.dispose();
  });

  test('assistant repeats an existing response', () async {
    final controller = AssistantController(
      listeningDuration: const Duration(milliseconds: 1),
      processingDuration: const Duration(milliseconds: 1),
      speakingDuration: const Duration(milliseconds: 1),
    );
    controller.startConversation();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    controller.repeatResponse();

    expect(controller.state, AssistantInteractionState.speaking);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(controller.state, AssistantInteractionState.confirmation);
    controller.dispose();
  });

  test(
    'stopping speech keeps the response and requests confirmation',
    () async {
      final controller = AssistantController(
        listeningDuration: const Duration(milliseconds: 1),
        processingDuration: const Duration(milliseconds: 1),
        speakingDuration: const Duration(milliseconds: 50),
      );
      controller.startConversation();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(controller.state, AssistantInteractionState.speaking);

      controller.stopSpeaking();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.state, AssistantInteractionState.confirmation);
      expect(controller.assistantResponse, isNotNull);
      controller.dispose();
    },
  );

  test('assistant exposes a recoverable error state', () {
    final controller = AssistantController();

    controller.showError();

    expect(controller.state, AssistantInteractionState.error);
    expect(controller.assistantResponse, 'Saya belum memahami tujuanmu.');
    controller.dispose();
  });
}
