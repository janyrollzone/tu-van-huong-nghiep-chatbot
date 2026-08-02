# Tư vấn hướng nghiệp THPT

Flutter Web chatbot tư vấn hướng nghiệp bằng tiếng Việt, sử dụng Gemini. Trợ lý hỏi về sở thích, môn mạnh, tính cách và mong muốn nghề nghiệp trước khi gợi ý ngành học.

## Chạy local

```powershell
flutter pub get
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key
```

Không commit API key. Trên GitHub Actions, đặt secret `GEMINI_API_KEY`.

## Kiểm thử

```powershell
dart format .
flutter analyze
flutter test
flutter build web --release --base-href "/tu-van-huong-nghiep-chatbot/" --dart-define=GEMINI_API_KEY=test-placeholder
```

Để kiểm thử đa lượt, nhập lần lượt sở thích, môn thế mạnh, tính cách và mong muốn nghề nghiệp. Kiểm tra bot tiếp tục hỏi thông tin còn thiếu, sau đó phản hồi 2–3 ngành có lý do, kỹ năng, nghề liên quan và tổ hợp xét tuyển tham khảo.
