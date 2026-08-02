import 'package:flutter_test/flutter_test.dart';
import 'package:tu_van_huong_nghiep_chatbot/main.dart';

void main() {
  testWidgets('shows configuration state without Supabase', (tester) async {
    await tester.pumpWidget(const CareerChatApp(isConfigured: false));
    expect(find.textContaining('Chưa cấu hình Supabase'), findsOneWidget);
  });
}
