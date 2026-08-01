import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../travel_alarm/domain/entities/travel_alarm_state.dart';
import '../../../travel_alarm/presentation/controllers/travel_alarm_controller.dart';
import '../../domain/entities/assistant_conversation_item.dart';

class AssistantConversationController extends ChangeNotifier {
  AssistantConversationController({required this.alarmController});

  final TravelAlarmController alarmController;
  final List<AssistantConversationItem> _items = [];
  int _nextId = 0;

  UnmodifiableListView<AssistantConversationItem> get items =>
      UnmodifiableListView(_items);

  void submitText(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;

    _append(
      author: AssistantMessageAuthor.user,
      kind: AssistantConversationItemKind.message,
      text: text,
    );
    _handleCommand(text.toLowerCase());
    notifyListeners();
  }

  void addVoiceExchange({
    required String transcript,
    required String response,
  }) {
    final normalized = transcript.trim().toLowerCase();
    _append(
      author: AssistantMessageAuthor.user,
      kind: AssistantConversationItemKind.message,
      text: transcript,
    );
    if (_isAlarmCommand(normalized)) {
      _handleCommand(normalized);
    } else {
      _append(
        author: AssistantMessageAuthor.assistant,
        kind: AssistantConversationItemKind.routeSuggestion,
        text: response,
      );
    }
    notifyListeners();
  }

  void _handleCommand(String normalized) {
    if (_requiresTicket(normalized) && !alarmController.state.hasActiveTicket) {
      _append(
        author: AssistantMessageAuthor.assistant,
        kind: AssistantConversationItemKind.noActiveTicket,
        text: 'Belum ada tiket aktif',
      );
      return;
    }

    if (normalized.contains('batalkan semua alarm')) {
      if (!alarmController.state.hasAnyAlarm) {
        _appendAssistant('Tidak ada alarm aktif.');
        return;
      }
      alarmController.cancelAllAlarms();
      _appendAssistant('Semua alarm perjalanan dibatalkan.');
      return;
    }

    if (normalized.contains('matikan alarm tujuan')) {
      if (!alarmController.state.destinationAlarmEnabled) {
        _appendAlarmStatus('Alarm tujuan sudah nonaktif.');
        return;
      }
      alarmController.disableDestinationAlarm();
      _appendAlarmStatus('Alarm tujuan dinonaktifkan.');
      return;
    }

    if (normalized.contains('aktifkan semua alarm')) {
      alarmController.configureAlarms(departure: true, destination: true);
      _appendAlarmStatus('Semua alarm perjalanan aktif.');
      return;
    }

    if (normalized.contains('alarm berikutnya')) {
      _appendAlarmStatus(alarmController.nextAlarmDescription);
      return;
    }

    if (normalized.contains('datang') || normalized.contains('berapa menit')) {
      _appendAssistant(
        'Kereta datang ${alarmController.state.minutesUntilTrain} menit lagi',
      );
      return;
    }

    _appendAssistant(
      'Saya belum memahami perintah itu. Coba: "Alarm berikutnya kapan?" atau "Aktifkan semua alarm tiket saya".',
    );
  }

  bool _requiresTicket(String text) {
    return text.contains('alarm') ||
        text.contains('kereta') ||
        text.contains('berapa menit');
  }

  bool _isAlarmCommand(String text) {
    return text.contains('alarm') ||
        text.contains('berapa menit') ||
        text.contains('kereta saya datang');
  }

  void _appendAssistant(String text) {
    _append(
      author: AssistantMessageAuthor.assistant,
      kind: AssistantConversationItemKind.message,
      text: text,
    );
  }

  void _appendAlarmStatus(String text) {
    _append(
      author: AssistantMessageAuthor.assistant,
      kind: AssistantConversationItemKind.alarmStatus,
      text: text,
      alarmSnapshot: alarmController.state,
    );
  }

  void _append({
    required AssistantMessageAuthor author,
    required AssistantConversationItemKind kind,
    required String text,
    TravelAlarmState? alarmSnapshot,
  }) {
    _items.add(
      AssistantConversationItem(
        id: _nextId++,
        author: author,
        kind: kind,
        text: text,
        alarmSnapshot: alarmSnapshot,
      ),
    );
  }
}
