import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tu_van_huong_nghiep_chatbot/main.dart';
import 'package:tu_van_huong_nghiep_chatbot/models/chat_message.dart';
import 'package:tu_van_huong_nghiep_chatbot/services/gemini_chat_service.dart';

class FakeChatService implements ChatService {
  @override
  Future<String> reply(List<ChatMessage> history) async =>
      'Em hợp với ngành Công nghệ thông tin.';
}

void main() {
  testWidgets('gửi tin nhắn và hiện phản hồi', (tester) async {
    await tester.pumpWidget(CareerChatApp(chatService: FakeChatService()));
    await tester.enterText(find.byType(EditableText), 'Em thích lập trình');
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Em thích lập trình'), findsOneWidget);
    expect(find.text('Em hợp với ngành Công nghệ thông tin.'), findsOneWidget);
  });
}
