import 'dart:async';

import 'package:flutter/foundation.dart';

enum AssistantInteractionState {
  ready,
  listening,
  processing,
  speaking,
  confirmation,
  error,
}

class AssistantController extends ChangeNotifier {
  AssistantController({
    this.listeningDuration = const Duration(milliseconds: 850),
    this.processingDuration = const Duration(milliseconds: 700),
    this.speakingDuration = const Duration(milliseconds: 650),
  });

  final Duration listeningDuration;
  final Duration processingDuration;
  final Duration speakingDuration;

  static const String demoOrigin = 'Setiabudi';
  static const String demoDestination = 'Manggarai';

  AssistantInteractionState state = AssistantInteractionState.ready;
  bool wakeWordEnabled = false;
  String? userTranscript;
  String? assistantResponse;

  Timer? _timer;

  void toggleWakeWord(bool value) {
    if (wakeWordEnabled == value) return;
    wakeWordEnabled = value;
    notifyListeners();
  }

  void startConversation() {
    _timer?.cancel();
    userTranscript = null;
    assistantResponse = null;
    _setState(AssistantInteractionState.listening);
    _timer = Timer(listeningDuration, _finishListening);
  }

  void repeatResponse() {
    if (assistantResponse == null) return;
    _timer?.cancel();
    _setState(AssistantInteractionState.speaking);
    _timer = Timer(speakingDuration, _finishSpeaking);
  }

  void stopSpeaking() {
    if (state != AssistantInteractionState.speaking) return;
    _timer?.cancel();
    _timer = null;
    _setState(AssistantInteractionState.confirmation);
  }

  void cancelConversation() {
    _timer?.cancel();
    _timer = null;
    userTranscript = null;
    assistantResponse = null;
    _setState(AssistantInteractionState.ready);
  }

  void showError() {
    _timer?.cancel();
    _timer = null;
    assistantResponse = 'Saya belum memahami tujuanmu.';
    _setState(AssistantInteractionState.error);
  }

  void _finishListening() {
    userTranscript = 'Saya ingin ke $demoDestination dari $demoOrigin.';
    _setState(AssistantInteractionState.processing);
    _timer = Timer(processingDuration, _finishProcessing);
  }

  void _finishProcessing() {
    assistantResponse =
        'Rute tercepat membutuhkan 7 menit. Kereta tiba 5 menit lagi.';
    _setState(AssistantInteractionState.speaking);
    _timer = Timer(speakingDuration, _finishSpeaking);
  }

  void _finishSpeaking() {
    _timer = null;
    _setState(AssistantInteractionState.confirmation);
  }

  void _setState(AssistantInteractionState value) {
    state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
