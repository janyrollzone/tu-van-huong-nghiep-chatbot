# Gemini system prompt

The system instruction is defined in `lib/services/gemini_chat_service.dart` so it is versioned with the application. It requires Vietnamese-only THPT career guidance, a four-part discovery phase, and a structured 2–3-major recommendation once enough information is available.

## Local configuration

Never place an API key in this file, `.env`, source code, or Git. Pass it only at build/run time:

```powershell
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_key
```
