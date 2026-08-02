enum MessageAuthor { user, model }

class ChatMessage {
  const ChatMessage({required this.author, required this.text});

  final MessageAuthor author;
  final String text;
}
