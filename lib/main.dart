import 'package:flutter/material.dart';

import 'screens/chat_page.dart';
import 'services/gemini_chat_service.dart';

void main() {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  runApp(CareerChatApp(chatService: GeminiChatService(apiKey: apiKey)));
}

class CareerChatApp extends StatelessWidget {
  const CareerChatApp({super.key, required this.chatService});

  final ChatService chatService;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Hướng Nghiệp THPT',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457C5)),
      useMaterial3: true,
    ),
    home: ChatPage(chatService: chatService),
  );
}
