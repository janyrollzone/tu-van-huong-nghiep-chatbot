import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/chat_message.dart';

abstract interface class ChatService {
  Future<String> reply(List<ChatMessage> history);
}

class ChatServiceException implements Exception {
  const ChatServiceException(this.message);
  final String message;
}

class GeminiChatService implements ChatService {
  GeminiChatService({required this.apiKey});

  final String apiKey;

  static const _systemInstruction =
      '''Bạn chỉ trả lời bằng tiếng Việt và là tư vấn viên hướng nghiệp cho học sinh THPT Việt Nam. Chỉ trao đổi về hướng nghiệp, ngành học, kỹ năng học tập và lựa chọn trường/nghề; với nội dung khác, hãy từ chối lịch sự và mời người dùng quay lại chủ đề hướng nghiệp.

Trước khi kết luận hoặc gợi ý ngành, hãy lần lượt tìm hiểu: sở thích, môn học thế mạnh, tính cách, và mong muốn nghề nghiệp. Nếu còn thiếu bất kỳ điểm nào, chỉ đặt câu hỏi ngắn, thân thiện để làm rõ. Khi đã đủ thông tin, gợi ý 2 đến 3 ngành. Mỗi ngành phải có lý do phù hợp, kỹ năng nên phát triển, nghề nghiệp liên quan và tổ hợp xét tuyển tham khảo. Luôn nói rõ tổ hợp xét tuyển có thể thay đổi theo từng trường và từng năm.''';

  @override
  Future<String> reply(List<ChatMessage> history) async {
    if (apiKey.trim().isEmpty) {
      throw const ChatServiceException(
        'Chưa cấu hình Gemini API key. Hãy chạy ứng dụng với --dart-define=GEMINI_API_KEY=... rồi thử lại.',
      );
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(_systemInstruction),
      );
      final contents = history
          .map(
            (message) => Content(
              message.author == MessageAuthor.user ? 'user' : 'model',
              [TextPart(message.text)],
            ),
          )
          .toList();
      final response = await model
          .generateContent(contents)
          .timeout(const Duration(seconds: 30));
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw const ChatServiceException(
          'Trợ lý chưa trả về nội dung. Bạn hãy thử lại sau ít phút.',
        );
      }
      return text;
    } on ChatServiceException {
      rethrow;
    } on TimeoutException {
      throw const ChatServiceException(
        'Kết nối tới trợ lý đã quá thời gian chờ. Vui lòng kiểm tra mạng và thử lại.',
      );
    } on GenerativeAIException catch (error) {
      throw ChatServiceException('Gemini không thể trả lời: ${error.message}');
    } catch (_) {
      throw const ChatServiceException(
        'Không thể kết nối với trợ lý lúc này. Vui lòng kiểm tra mạng rồi thử lại.',
      );
    }
  }
}
