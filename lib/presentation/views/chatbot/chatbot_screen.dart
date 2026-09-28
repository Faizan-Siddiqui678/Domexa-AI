import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/chatbot_viewmodel.dart';
import '../../../data/models/chat_message_model.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatbotViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.primary, size: 20),
            ),
          ),
          title: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.psychology_outlined,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Civil Expert',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Text('Online • Ready to help',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.cardMaterials)),
              ],
            ),
          ]),
          actions: [
            Consumer<ChatbotViewModel>(
              builder: (ctx, vm, _) => vm.hasMessages
                  ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 18),
                ),
                onPressed: () => _showClearDialog(ctx, vm),
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<ChatbotViewModel>(
          builder: (ctx, vm, _) => Column(
            children: [
              if (!vm.hasMessages) _buildSuggestedQuestions(vm),
              Expanded(
                child: vm.hasMessages
                    ? _buildMessagesList(vm)
                    : _buildEmptyState(),
              ),
              if (vm.isTyping) _buildTypingIndicator(),
              if (vm.errorMessage != null)
                _buildErrorBanner(vm.errorMessage!),
              _buildInputBar(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions(ChatbotViewModel vm) {
    final questions = vm.getSuggestedQuestions();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Suggested Questions',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                fontSize: 12)),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: questions.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () {
                _msgCtrl.text = questions[i];
                vm.sendMessage(questions[i]);
                _msgCtrl.clear();
                _scrollToBottom();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(questions[i],
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.psychology_outlined,
                color: Colors.white, size: 42),
          ),
          const SizedBox(height: 20),
          const Text('AI Civil Engineering Expert',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ask me anything about construction,\nmaterials, layouts, or costs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatbotViewModel vm) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: vm.messages.length,
      itemBuilder: (ctx, i) => _buildMessage(vm.messages[i]),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.psychology_outlined,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.primaryGradient : null,
                color: isUser ? null : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: isUser ? null : AppColors.cardShadow,
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                    color: isUser ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.psychology_outlined,
              color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.cardShadow),
          child: Row(children: [
            _dot(0),
            const SizedBox(width: 4),
            _dot(200),
            const SizedBox(width: 4),
            _dot(400),
          ]),
        ),
      ]),
    );
  }

  Widget _dot(int delayMs) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMs)),
      builder: (ctx, snap) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (_, val, __) => Opacity(
            opacity: snap.connectionState == ConnectionState.done ? val : 0.0,
            child: Container(
              width: 8, height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: const BoxDecoration(
                  color: Colors.white70, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(10),
          border:
          Border.all(color: AppColors.error.withValues(alpha: 0.3))),
      child: Row(children: [
        const Icon(Icons.wifi_off, color: AppColors.error, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 12))),
      ]),
    );
  }

  Widget _buildInputBar(ChatbotViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _msgCtrl,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ask about construction, materials...',
              hintStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppColors.bgInput,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 2)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: vm.isTyping
              ? null
              : () {
            final msg = _msgCtrl.text.trim();
            if (msg.isEmpty) return;
            vm.sendMessage(msg);
            _msgCtrl.clear();
            _scrollToBottom();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: vm.isTyping ? null : AppColors.primaryGradient,
              color: vm.isTyping ? AppColors.border : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: vm.isTyping
                  ? null
                  : [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Icon(
              vm.isTyping ? Icons.hourglass_empty : Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ]),
    );
  }

  void _showClearDialog(BuildContext context, ChatbotViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Delete all messages?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              vm.clearConversation();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}