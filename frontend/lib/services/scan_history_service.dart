import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_result.dart';

/// Service to persist and retrieve scan history locally
class ScanHistoryService {
  static const String _historyKey = 'scan_history';
  static const int _maxHistory = 20;

  /// Save a scan result to local history
  static Future<void> saveScan(AnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    final entry = {
      'product_name': result.productName,
      'danger_level': result.dangerLevel,
      'health_score': result.healthScore,
      'verdict': result.verdict,
      'summary': result.summary,
      'alerts_count': result.alerts.length,
      'alternatives_count': result.alternatives.length,
      'timestamp': DateTime.now().toIso8601String(),
      'alerts': result.alerts.map((a) => {
        'ingredient': a.ingredient,
        'severity': a.severity,
        'risk': a.risk,
        'reason': a.reason,
        'side_effects': a.sideEffects,
      }).toList(),
      'alternatives': result.alternatives,
    };

    history.insert(0, entry);

    // Keep only the most recent scans
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  /// Get all scan history entries
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Reconstruct an AnalysisResult from a history entry
  static AnalysisResult resultFromHistory(Map<String, dynamic> entry) {
    return AnalysisResult.fromJson(entry);
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
