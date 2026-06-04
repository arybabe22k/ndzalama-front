class Transaction {
  final int id;
  final double amount;
  final String category;
  final String description;
  final String? merchant;
  final String? location;
  final DateTime transactionDate;
  final String transactionType;
  final String paymentMethod;
  final int? impulseScore;
  final String? riskLevel;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    this.merchant,
    this.location,
    required this.transactionDate,
    required this.transactionType,
    required this.paymentMethod,
    this.impulseScore,
    this.riskLevel,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? 'OTHER',
      description: json['description'] ?? '',
      merchant: json['merchant'],
      location: json['location'],
      transactionDate: DateTime.parse(json['transactionDate'] ?? DateTime.now().toIso8601String()),
      transactionType: json['transactionType'] ?? 'EXPENSE',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      impulseScore: json['impulseScore'],
      riskLevel: json['riskLevel'],
    );
  }
}

class TransactionAnalysisResult {
  final int transactionId;
  final int impulseScore;
  final String riskLevel;
  final String recommendation;
  final String reason;

  TransactionAnalysisResult({
    required this.transactionId,
    required this.impulseScore,
    required this.riskLevel,
    required this.recommendation,
    required this.reason,
  });

  factory TransactionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return TransactionAnalysisResult(
      transactionId: json['transactionId'] ?? 0,
      impulseScore: json['impulseScore'] ?? 0,
      riskLevel: json['riskLevel'] ?? 'BAIXO',
      recommendation: json['recommendation'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}