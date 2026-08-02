import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';

abstract interface class ChatService {
  Future<String> reply(List<ChatMessage> history);
}

class ChatServiceException implements Exception {
  const ChatServiceException(this.message);
  final String message;
}

class SupabaseChatService implements ChatService {
  const SupabaseChatService(this._client);
  final SupabaseClient _client;

  @override
  Future<String> reply(List<ChatMessage> history) async {
    try {
      final result = await _client.functions
          .invoke(
            'career-chat',
            body: {
              'messages': history
                  .map(
                    (message) => {
                      'role': message.author == MessageAuthor.user
                          ? 'user'
                          : 'model',
                      'parts': [
                        {'text': message.text},
                      ],
                    },
                  )
                  .toList(),
            },
          )
          .timeout(const Duration(seconds: 35));
      if (result.status != 200 || result.data is! Map) {
        final message = result.data is Map
            ? (result.data as Map)['error']?.toString()
            : null;
        throw ChatServiceException(
          message ?? 'Trợ lý hiện không thể trả lời. Vui lòng thử lại.',
        );
      }
      final text = (result.data as Map)['text']?.toString().trim();
      if (text == null || text.isEmpty) {
        throw const ChatServiceException(
          'Trợ lý chưa trả về nội dung. Vui lòng thử lại.',
        );
      }
      return text;
    } on ChatServiceException {
      rethrow;
    } catch (_) {
      throw const ChatServiceException(
        'Không thể kết nối với trợ lý. Vui lòng kiểm tra mạng và thử lại.',
      );
    }
  }
}
