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
  final _input = TextEditingController(), _scroll = ScrollController();
  final _messages = <ChatMessage>[
    const ChatMessage(
      author: MessageAuthor.model,
      text: 'Chào em! Hãy kể về sở thích của mình trước nhé?',
    ),
  ];
  bool _loading = false;
  String? _error;
  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(ChatMessage(author: MessageAuthor.user, text: text));
      _input.clear();
      _loading = true;
      _error = null;
    });
    try {
      final reply = await widget.chatService.reply(
        List.unmodifiable(_messages),
      );
      if (mounted)
        setState(
          () => _messages.add(
            ChatMessage(author: MessageAuthor.model, text: reply),
          ),
        );
    } on ChatServiceException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: c.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.explore, color: c.onPrimary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hướng nghiệp AI',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Phiên tư vấn cá nhân'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Supabase.instance.client.auth.signOut(),
                        icon: const Icon(Icons.logout_outlined),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Khám phá con đường phù hợp với bạn',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    children: ['Sở thích', 'Môn mạnh', 'Mong muốn nghề nghiệp']
                        .map(
                          (x) => ActionChip(
                            label: Text(x),
                            onPressed: () {
                              _input.text = x;
                              _send();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (_, i) => i == _messages.length
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : MessageBubble(message: _messages[i]),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MaterialBanner(
                      content: Text(_error!),
                      actions: [
                        TextButton(
                          onPressed: _send,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                Container(
                  color: c.surfaceContainerLow,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Nhập câu trả lời của em...',
                            filled: true,
                            fillColor: c.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _loading ? null : _send,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
