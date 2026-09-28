import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/api_service.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ApiService _apiService;
  ChatbotViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final List<ChatMessage> _messages = [];
  bool    _isTyping     = false;
  String? _errorMessage;
  String  _city         = 'lahore';

  List<ChatMessage> get messages    => List.unmodifiable(_messages);
  bool    get isTyping              => _isTyping;
  String? get errorMessage          => _errorMessage;
  bool    get hasMessages           => _messages.isNotEmpty;
  String  get city                  => _city;

  void setCity(String v) { _city = v.toLowerCase(); notifyListeners(); }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;
    _messages.add(ChatMessage(role: 'user', content: userMessage.trim()));
    _errorMessage = null;
    _isTyping     = true;
    notifyListeners();
    try {
      final response = await _apiService.sendChatMessage(
        message:             userMessage,
        conversationHistory: _messages.sublist(0, _messages.length - 1),
        city:                _city,
      );
      _messages.add(ChatMessage(role: 'assistant', content: response));
      _isTyping = false;
      notifyListeners();
    } catch (e) {
      _isTyping     = false;
      _errorMessage = e is ApiException ? e.message : e.toString();
      _messages.add(ChatMessage(
        role: 'assistant',
        content: 'Sorry, I could not get a response right now.\n\n'
            'Make sure the backend server is running on your PC '
            'and your phone is on the same WiFi network.',
      ));
      notifyListeners();
    }
  }

  void clearConversation() {
    _messages.clear();
    _errorMessage = null;
    _isTyping     = false;
    notifyListeners();
  }

  List<String> getSuggestedQuestions() => [
    'How much does a 10 Marla house cost?',
    'What is the best cement for foundation?',
    'How to cast a roof slab?',
    'Which direction should the kitchen face?',
    'What is the standard room height in Pakistan?',
    'How to waterproof a basement?',
    'What steel grade should I use for columns?',
    'What is the difference between OPC and PPC cement?',
  ];

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
