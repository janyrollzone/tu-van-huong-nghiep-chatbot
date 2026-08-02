import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';
import '../services/gemini_chat_service.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatService});
  final ChatService chatService;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    const ChatMessage(
      author: MessageAuthor.model,
      text:
          'Chào em! Thầy/cô là trợ lý hướng nghiệp THPT. Em hãy kể về sở thích của mình trước nhé?',
    ),
  ];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final input = _inputController.text.trim();
    if (input.isEmpty || _isLoading) return;
    setState(() {
      _messages.add(ChatMessage(author: MessageAuthor.user, text: input));
      _inputController.clear();
      _isLoading = true;
      _error = null;
    });
    _scrollToEnd();

    try {
      final reply = await widget.chatService.reply(
        List.unmodifiable(_messages),
      );
      if (!mounted) return;
      setState(
        () => _messages.add(
          ChatMessage(author: MessageAuthor.model, text: reply),
        ),
      );
    } on ChatServiceException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Đã có lỗi không mong muốn. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToEnd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(24, 18, 16, 12), child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.explore_rounded, color: colors.onPrimary)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hướng nghiệp AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), Text('Khám phá lộ trình phù hợp với bạn', style: TextStyle(fontSize: 13))])),
            IconButton(onPressed: () => Supabase.instance.client.auth.signOut(), tooltip: 'Đăng xuất', icon: const Icon(Icons.logout_outlined)),
          ])),
          Container(height: 1, color: colors.outlineVariant),
          Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 6), child: Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Phiên tư vấn cá nhân', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 4), const Text('Hãy chia sẻ để nhận được gợi ý ngành học phù hợp nhất.')]))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Wrap(spacing: 8, runSpacing: 8, children: ['Sở thích của em', 'Môn em học tốt', 'Điều em mong muốn'].map((label) => ActionChip(label: Text(label), onPressed: _isLoading ? null : () { _inputController.text = label; _send(); })).toList())),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) => index == _messages.length
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : MessageBubble(message: _messages[index]),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MaterialBanner(
                    content: Text(_error!),
                    actions: [
                      TextButton(
                        onPressed: _isLoading ? null : _send,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              Container(decoration: BoxDecoration(color: colors.surfaceContainerLow, border: Border(top: BorderSide(color: colors.outlineVariant))), padding: const EdgeInsets.all(16), child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Nhập câu trả lời của em...',
                          filled: true, fillColor: colors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isLoading ? null : _send,
                      tooltip: 'Gửi',
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              )),
            ])),
          ),
        )),
      );
  }
}
