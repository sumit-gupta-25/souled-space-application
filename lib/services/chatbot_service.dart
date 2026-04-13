import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String baseUrl =
      "https://souled-space-chatbot.onrender.com/chat";

  static Future<String> sendMessage(String message) async {
    try {
      print("Sending: $message");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("Parsed Data: $data");

        return data["reply"] ?? "No reply from server";
      } else {
        return "I'm here with you 🤍";
      }
    } catch (e) {
      print("ERROR: $e");
      return "Something went wrong, but I'm still here for you 🤍";
    }
  }
}
