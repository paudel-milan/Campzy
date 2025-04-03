import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String apiKey = "AIzaSyBtw21RFLNUx2iDk293WgWVsQe8-6eysqQ"; // Replace with your actual API key
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey"; // Corrected model

  static Future<String> getResponse(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {"parts": [{"text": userInput}]}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debugging response
        print("Response: ${response.body}");

        return data["candidates"]?[0]["content"]["parts"]?[0]["text"] ??
            "I didn't understand that.";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Failed to connect: $e";
    }
  }
}