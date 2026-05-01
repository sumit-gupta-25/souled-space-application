import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart'; // Add uuid to pubspec.yaml

class ChatbotService {
  static const String _baseUrl = "https://souled-space-ai-chatbot.onrender.com";

  // One session ID per app launch — persists across messages in the same session
  static String _sessionId = const Uuid().v4();

  // ── Send a message ────────────────────────────────────────────────────────
  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "sessionId": _sessionId, // Required for conversation memory
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "I'm here with you 🤍";
      } else {
        return "I'm here with you 🤍";
      }
    } catch (e) {
      return "Something went wrong, but I'm still here for you 🤍";
    }
  }

  // ── Reset conversation (call when user taps "New Chat" or logs out) ───────
  static Future<void> resetConversation() async {
    try {
      await http.post(
        Uri.parse("$_baseUrl/reset"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sessionId": _sessionId}),
      );
    } catch (_) {
      // Silent fail — reset is non-critical
    } finally {
      // Always generate a new session ID locally
      _sessionId = const Uuid().v4();
    }
  }

  // ── Get current session ID (useful for debugging) ─────────────────────────
  static String get sessionId => _sessionId;
}
