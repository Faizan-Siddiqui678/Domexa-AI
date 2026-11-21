class ChatMessageModel {
  final String role; // 'user' | 'assistant' (what ChatRequest.conversation_history expects)
  final String content;
  final DateTime time;
  final bool isError;
  ChatMessageModel({required this.role, required this.content, DateTime? time, this.isError = false})
      : time = time ?? DateTime.now();
  bool get isUser => role == 'user';
  Map<String, String> toApi() => {'role': role, 'content': content};
}