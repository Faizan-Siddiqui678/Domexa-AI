import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chat_message_model.dart';
import '../../viewmodels/chatbot_viewmodel.dart';
import '../../viewmodels/plot_input_viewmodel.dart';
import '../../widgets/chat_markdown.dart';
import '../../widgets/common_widgets.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String t) async {
    final city = context.read<PlotInputViewModel>().city;
    _text.clear();
    final f = context.read<ChatbotViewModel>().send(t, city);
    _toBottom();
    await f;
    _toBottom();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  });

  Future<void> _confirmClear() async {
    final vm = context.read<ChatbotViewModel>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear this conversation?'),
        content: const Text('All messages will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) vm.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatbotViewModel>();
    final city = context.watch<PlotInputViewModel>().city;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI assistant'),
        actions: [
          if (vm.messages.isNotEmpty) IconButton(tooltip: 'Clear conversation', icon: const Icon(Icons.delete_sweep_outlined), onPressed: _confirmClear),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: vm.messages.isEmpty
              ? ListView(padding: const EdgeInsets.all(16), children: [
            const InfoNote('Ask about costs, materials, structure or climate. Answers are general guidance - confirm important decisions with a licensed engineer.', title: 'Your civil engineering helper'),
            const SizedBox(height: 8),
            Text('Try asking', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in ChatbotViewModel.suggestions) ActionChip(label: Text(s), onPressed: () => _send(s)),
            ]),
          ])
              : ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: vm.messages.length + (vm.sending ? 1 : 0),
            itemBuilder: (c, i) {
              if (i == vm.messages.length) return const _Typing();
              final m = vm.messages[i];
              return _Bubble(m: m, onRetry: m.isError && i == vm.messages.length - 1 ? () => vm.retry(city) : null);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Type your question...'),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: vm.sending ? null : _send,
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: 'Send',
                onPressed: (vm.sending || _text.text.trim().isEmpty) ? null : () => _send(_text.text),
                icon: const Icon(Icons.send),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.m, this.onRetry});
  final ChatMessageModel m;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final user = m.isUser;
    final bg = m.isError ? AppColors.errorBg : (user ? AppColors.primary : AppColors.surface);
    final fg = m.isError ? AppColors.error : (user ? Colors.white : AppColors.text);
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        label: '${user ? 'You' : 'Assistant'}: ${m.content}',
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: user ? null : Border.all(color: m.isError ? AppColors.error.withAlpha(80) : AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            (user || m.isError)
                ? SelectableText(m.content, style: TextStyle(color: fg, height: 1.4))
                : ChatMarkdown(m.content, color: fg),
            if (onRetry != null) TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ]),
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Assistant is typing',
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.5)),
          SizedBox(width: 10),
          Text('Thinking...'),
        ]),
      ),
    ),
  );
}