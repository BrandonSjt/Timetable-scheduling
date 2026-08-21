abstract interface class AssistantChatRepository {
  Future<String> ask(String message);
}
