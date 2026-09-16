import 'dart:async';

import 'package:timetable/features/assistant/domain/repositories/assistant_chat_repository.dart';

class FakeAssistantChatRepository implements AssistantChatRepository {
  static const answer = AssistantChatAnswer(
    reply: 'Naik KRL dari Bekasi menuju Jakarta Kota, transit di Manggarai.',
    routeFrom: 'Bekasi',
    routeTo: 'Jakarta Kota',
  );
  final List<String> messages = [];
  List<AssistantChatTurn> lastHistory = [];
  Completer<AssistantChatAnswer>? pending;
  AssistantChatException? error;

  @override
  Future<AssistantChatAnswer> ask(
    String message, {
    List<AssistantChatTurn> history = const [],
    String? lang,
  }) async {
    messages.add(message);
    lastHistory = history;
    if (error != null) throw error!;
    return pending == null ? answer : pending!.future;
  }
}
