import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  static final String apiKey = dotenv.env['HF_API_KEY'] ?? ''; // Load from .env
  static final String apiUrl = "https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill";
// Correct API

  static Future<String> getResponse(String userInput) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey", // Correct Auth Header
          "Content-Type": "application/json"
        },
        body: jsonEncode({"inputs": userInput}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0].containsKey("generated_text")) {
          return data[0]["generated_text"];
        }
        return "Invalid response format from AI.";
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Failed to connect: $e";
    }
  }
}
