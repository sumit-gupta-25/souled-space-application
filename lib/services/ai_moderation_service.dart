import 'dart:convert';
import 'package:http/http.dart' as http;

class AiModerationService {
  static const String baseUrl =
      "https://souled-space-ai-moderator.onrender.com/moderate";

  static Future<Map<String, dynamic>> checkText(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": text}),
          )
          .timeout(const Duration(seconds: 5));

      return jsonDecode(response.body);
    } catch (e) {
      return {"decision": "allow"}; // fail-safe
    }
  }
}
