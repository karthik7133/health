class AnalysisResult {
  final String productName;
  final String dangerLevel;
  final int healthScore;
  final String verdict;
  final String summary;
  final List<IngredientAlert> alerts;
  final List<String> alternatives;
  final String rawIngredientsText; // Store original scanned text for chatbot

  AnalysisResult({
    required this.productName,
    required this.dangerLevel,
    required this.healthScore,
    required this.verdict,
    required this.summary,
    required this.alerts,
    required this.alternatives,
    this.rawIngredientsText = '',
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json, {String ingredientsText = ''}) {
    return AnalysisResult(
      productName: json['product_name'] ?? 'Unknown Product',
      dangerLevel: json['danger_level'] ?? 'Unknown',
      healthScore: json['health_score'] ?? 0,
      verdict: json['verdict'] ?? 'Unknown',
      summary: json['summary'] ?? '',
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => IngredientAlert.fromJson(e))
              .toList() ??
          [],
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rawIngredientsText: ingredientsText,
    );
  }

  /// Generate a context string for the chatbot
  String toChatContext() {
    final alertNames = alerts.map((a) => a.ingredient).join(', ');
    return 'Product: $productName. Health Score: $healthScore/10. Verdict: $verdict. '
        'Danger Level: $dangerLevel. Key ingredients flagged: $alertNames. '
        'Summary: $summary';
  }
}

class IngredientAlert {
  final String ingredient;
  final String severity; // "High", "Medium", "Low"
  final String risk;
  final String reason;
  final List<String> sideEffects;

  IngredientAlert({
    required this.ingredient,
    required this.severity,
    required this.risk,
    required this.reason,
    required this.sideEffects,
  });

  factory IngredientAlert.fromJson(Map<String, dynamic> json) {
    return IngredientAlert(
      ingredient: json['ingredient'] ?? '',
      severity: json['severity'] ?? 'Low',
      risk: json['risk'] ?? '',
      reason: json['reason'] ?? '',
      sideEffects: (json['side_effects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
