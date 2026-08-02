import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_page.dart';
import 'screens/chat_page.dart';
import 'services/gemini_chat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isNotEmpty && anonKey.isNotEmpty) {
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
  runApp(CareerChatApp(isConfigured: url.isNotEmpty && anonKey.isNotEmpty));
}

class CareerChatApp extends StatelessWidget {
  const CareerChatApp({super.key, required this.isConfigured});
  final bool isConfigured;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Hướng Nghiệp THPT',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457C5)),
      useMaterial3: true,
    ),
    home: !isConfigured
        ? const Scaffold(
            body: Center(
              child: Text('Chưa cấu hình Supabase. Vui lòng thử lại sau.'),
            ),
          )
        : const _AuthGate(),
  );
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    builder: (_, snapshot) {
      final session =
          snapshot.data?.session ??
          Supabase.instance.client.auth.currentSession;
      return session == null
          ? const AuthPage()
          : ChatPage(
              chatService: SupabaseChatService(Supabase.instance.client),
            );
    },
  );
}
