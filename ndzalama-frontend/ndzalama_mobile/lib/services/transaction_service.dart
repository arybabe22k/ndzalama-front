import '../models/transaction.dart';
import 'api_service.dart';

class TransactionService {
  final ApiService _api = ApiService();

  /// Cria e analisa transação (retorna MAP)
  Future<TransactionAnalysisResult> createAndAnalyzeTransaction(Map<String, dynamic> data) async {
    try {
      final response = await _api.postMap('/v1/financial/transactions/analyze', data);
      return TransactionAnalysisResult.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar transação: $e');
    }
  }

  /// Busca transações do usuário (retorna LIST)
  Future<List<Transaction>> getUserTransactions() async {
    try {
      final List<dynamic> response = await _api.getList('/v1/transactions');
      return response.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações: $e');
    }
  }

  /// Busca transações recentes (retorna LIST)
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    try {
      final List<dynamic> response = await _api.getList('/v1/transactions/recent?limit=$limit');
      return response.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações recentes: $e');
    }
  }

  /// Busca transações por período (retorna LIST)
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      final String startStr = start.toIso8601String();
      final String endStr = end.toIso8601String();
      final List<dynamic> response = await _api.getList('/v1/transactions/range?start=$startStr&end=$endStr');
      return response.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações por período: $e');
    }
  }
}