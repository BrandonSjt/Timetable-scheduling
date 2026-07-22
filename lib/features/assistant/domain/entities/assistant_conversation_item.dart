import 'package:flutter/foundation.dart';

enum AssistantMessageAuthor { user, assistant }

enum AssistantConversationItemKind { message, alarmStatus, noActiveTicket }

@immutable
class AssistantConversationItem {
  const AssistantConversationItem({
    required this.id,
    required this.author,
    required this.kind,
    required this.text,
  });

  final int id;
  final AssistantMessageAuthor author;
  final AssistantConversationItemKind kind;
  final String text;
}
