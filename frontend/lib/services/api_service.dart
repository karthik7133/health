import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class ApiService {
  // Use local IP for physical device
  static const String baseUrl = 'http://192.168.0.105:5000/api'; 

  Future<AnalysisResult> analyzeText(String text, {String? userId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ingredientsText': text,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return AnalysisResult.fromJson(
          jsonDecode(response.body),
          ingredientsText: text,
        );
      } else {
        throw Exception('Failed to analyze text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error identifying product: $e');
    }
  }

  Future<void> createUserProfile(String name, List<String> conditions, List<String> preferences) async {
    await http.post(
      Uri.parse('$baseUrl/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'healthConditions': conditions,
        'dietaryPreferences': preferences,
      }),
    );
  }
}
