class FinancialHealth {
  final int healthScore;
  final String healthClassification;
  final String colorCode;
  final double monthlyAvgIncome;
  final double monthlyAvgExpense;
  final double savingsRate;
  final double impulsePurchaseRate;
  final double debtToIncomeRatio;
  final double emergencyFundMonths;
  final List<String> riskFactors;
  final List<String> positiveFactors;
  final String behavioralProfile;
  final String profileDescription;
  final FuturePrediction futurePrediction;

  FinancialHealth({
    required this.healthScore,
    required this.healthClassification,
    required this.colorCode,
    required this.monthlyAvgIncome,
    required this.monthlyAvgExpense,
    required this.savingsRate,
    required this.impulsePurchaseRate,
    required this.debtToIncomeRatio,
    required this.emergencyFundMonths,
    required this.riskFactors,
    required this.positiveFactors,
    required this.behavioralProfile,
    required this.profileDescription,
    required this.futurePrediction,
  });

  factory FinancialHealth.fromJson(Map<String, dynamic> json) {
    return FinancialHealth(
      healthScore: json['healthScore'] ?? 0,
      healthClassification: json['healthClassification'] ?? 'REGULAR',
      colorCode: json['colorCode'] ?? '#F59E0B',
      monthlyAvgIncome: (json['monthlyAvgIncome'] ?? 0).toDouble(),
      monthlyAvgExpense: (json['monthlyAvgExpense'] ?? 0).toDouble(),
      savingsRate: (json['savingsRate'] ?? 0).toDouble(),
      impulsePurchaseRate: (json['impulsePurchaseRate'] ?? 0).toDouble(),
      debtToIncomeRatio: (json['debtToIncomeRatio'] ?? 0).toDouble(),
      emergencyFundMonths: (json['emergencyFundMonths'] ?? 0).toDouble(),
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
      positiveFactors: List<String>.from(json['positiveFactors'] ?? []),
      behavioralProfile: json['behavioralProfile'] ?? 'BALANCED',
      profileDescription: json['profileDescription'] ?? '',
      futurePrediction: FuturePrediction.fromJson(json['futurePrediction'] ?? {}),
    );
  }
}

class FuturePrediction {
  final double predictedMonthlySpend;
  final double confidence;
  final String trend;
  final String advice;

  FuturePrediction({
    required this.predictedMonthlySpend,
    required this.confidence,
    required this.trend,
    required this.advice,
  });

  factory FuturePrediction.fromJson(Map<String, dynamic> json) {
    return FuturePrediction(
      predictedMonthlySpend: (json['predictedMonthlySpend'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      trend: json['trend'] ?? 'ESTÁVEL',
      advice: json['advice'] ?? '',
    );
  }
}

class Insight {
  final int id;
  final String type;
  final String title;
  final String description;
  final int impactScore;
  final DateTime createdAt;
  final DateTime expiresAt;

  Insight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.impactScore,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id'] ?? 0,
      type: json['insightType'] ?? 'TIP',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      impactScore: json['impactScore'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}