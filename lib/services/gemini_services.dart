import 'dart:convert';
import 'package:http/http.dart' as http;
import 'toolmanager.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyDTVSgr5H6JHsXroqZEZnN12FAtqd3qRlQ';

  // =========================
  // CHAT WITH CONFIG + TOOLS
  // =========================
  Future<String> sendMessage(
    String message, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    try {
      // TOOL FIRST (local execution)
      final toolResult = ToolManager.execute(message);
      if (toolResult != null) {
        return toolResult.response;
      }

    final url = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
);

      // SAFE BODY BUILD (prevents 400 errors)
      final body = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": message}
            ]
          }
        ],
        "generationConfig": {
          "temperature": temperature,
          "maxOutputTokens": maxTokens,
        }
      };

      // system prompt optional add
      if (systemPrompt != null && systemPrompt.trim().isNotEmpty) {
        body["systemInstruction"] = {
          "parts": [
            {"text": systemPrompt}
          ]
        };
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }

      return "Error ${response.statusCode}: ${response.body}";
    } catch (e) {
      return "Exception: $e";
    }
  }

  // =========================
  // PROMPT EVALUATION (SEPARATE MODE)
  // =========================
  Future<String> evaluatePrompt({
    required String systemPrompt,
    required String userPrompt,
    required double temperature,
    required int maxTokens,
  }) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "systemInstruction": {
            "parts": [
              {"text": systemPrompt}
            ]
          },
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": userPrompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": temperature,
            "maxOutputTokens": maxTokens,
          }
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }

      return "Error ${response.statusCode}: ${response.body}";
    } catch (e) {
      return "Exception: $e";
    }
  }
}