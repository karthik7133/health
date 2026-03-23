import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String baseUrl = 'http://192.168.0.105:5000/api';

  Future<String> sendMessage(String message, {String? productContext}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'productContext': productContext,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response';
      } else {
        throw Exception('Failed to get response');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
