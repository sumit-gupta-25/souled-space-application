import 'package:http/http.dart' as http;
import 'dart:convert';

class StressDetectionService {
  static const String API_URL = 'https://souled-space-ml-server.onrender.com';

  static Future<Map<String, dynamic>?> analyzeText(String text) async {
    try {
      if (text.trim().isEmpty) {
        return null;
      }

      print('🔍 Analyzing text: "$text"');
      print('📡 Sending to: $API_URL/predict-stress');

      final response = await http
          .post(
            Uri.parse('$API_URL/predict-stress'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout - Server not responding');
            },
          );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          '✅ Analysis Result: ${data['prediction']} (${data['stress_level']}%)',
        );

        return {
          'stress_level': data['stress_level'].toDouble(),
          'prediction': data['prediction'],
          'success': data['success'],
        };
      } else {
        throw Exception('Failed to analyze text: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error analyzing text: $e');
      return null;
    }
  }
}
