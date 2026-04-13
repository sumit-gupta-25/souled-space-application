import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SocialMediaService {
  final String baseUrl = dotenv.get('baseUrl', fallback: 'URL_NOT_FOUND');

  //Fetches Instagram posts using the new Custom Playwright API
  Future<List<dynamic>> fetchInstagramPosts(String username) async {
    try {
      // 1. Correct endpoint call
      final response = await http
          .get(Uri.parse('$baseUrl/scrape?username=$username'))
          .timeout(const Duration(seconds: 45)); // Scrapers are slow, give it time

      if (response.statusCode == 200) {
        debugPrint("RAW JSON FROM PYTHON: ${response.body}");
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // 2. Access the 'data' object directly
          // This is where 'text' and 'timestamp' live
          final Map<String, dynamic> innerData = responseData['data'];

          // 3. Wrap it in a list so your 'for (var post in postsData)' loop works
          return [
            {"text": innerData['text'], "timestamp": innerData['timestamp']},
          ];
        }
      }
    } catch (e) {
      debugPrint("Instagram Scrape Error: $e");
    }
    return [];
  }

  /// Fetches X posts with their actual platform timestamps
  Future<List<dynamic>> fetchXPosts(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/scrape/x?username=$username'));
      if (response.statusCode == 200) {
        debugPrint("RAW JSON FROM PYTHON: ${response.body}");
        final data = json.decode(response.body);

        // Return the raw list of maps: [{"text": "...", "timestamp": "..."}]
        return data['posts'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint("X Scrape Error: $e");
    }
    return [];
  }
}
