import 'package:flutter/foundation.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/api_service.dart';

class ChatbotViewModel extends ChangeNotifier {
  ChatbotViewModel(this._api);
  final ApiService _api;

  static const suggestions = [
    'How much does a 10 Marla house cost?',
    'Which cement is best for foundations?',
    'How much steel does a 2-storey house need?',
    'How can I keep my house cooler in summer?',
  ];

  final List<ChatMessageModel> messages = [];
  bool sending = false;
  String? _lastUserText;

  Future<void> send(String text, String city) async {
    final t = text.trim();
    if (t.isEmpty || sending) return;
    _lastUserText = t;
    // History = last 10 successful messages BEFORE this one (backend appends the new message itself).
    final history = messages.where((m) => !m.isError).toList();
    final trimmed = history.length > 10 ? history.sublist(history.length - 10) : history;
    messages.add(ChatMessageModel(role: 'user', content: t));
    sending = true;
    notifyListeners();
    try {
      final reply = await _api.chat(message: t, history: trimmed, city: city);
      messages.add(ChatMessageModel(role: 'assistant', content: reply));
    } on ApiException catch (e) {
      messages.add(ChatMessageModel(role: 'assistant', content: e.message, isError: true));
    } catch (_) {
      messages.add(ChatMessageModel(role: 'assistant', content: 'Something unexpected happened.', isError: true));
    }
    sending = false;
    notifyListeners();
  }

  /// Re-asks the last question after a failure without retyping it.
  Future<void> retry(String city) async {
    if (_lastUserText == null || sending) return;
    if (messages.isNotEmpty && messages.last.isError) messages.removeLast();
    if (messages.isNotEmpty && messages.last.isUser) messages.removeLast();
    await send(_lastUserText!, city);
  }

  void clear() {
    messages.clear();
    _lastUserText = null;
    notifyListeners();
  }
}