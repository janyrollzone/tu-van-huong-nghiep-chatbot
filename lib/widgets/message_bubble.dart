import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == MessageAuthor.user;
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser)
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.auto_awesome, size: 17),
          ),
        if (!isUser) const SizedBox(width: 10),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? colors.onPrimary : colors.onSurface,
              ),
            ),
          ),
        ),
        if (isUser) const SizedBox(width: 10),
        if (isUser)
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.primaryContainer,
            child: Icon(
              Icons.person,
              size: 17,
              color: colors.onPrimaryContainer,
            ),
          ),
      ],
    );
  }
}
