import 'package:flutter/material.dart';
import 'package:ndzalama_mobile/models/FinancialHealth.dart';

import '../models/transaction.dart';
import 'api_service.dart';

class FinancialService {
  final ApiService _api = ApiService();

  /// Busca relatório de saúde financeira (retorna MAP)
  Future<FinancialHealth> getHealthReport() async {
    try {
      final response = await _api.getMap('/v1/financial-behavior/health-report');
      return FinancialHealth.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar health report: $e');
    }
  }

  /// Busca insights do usuário (retorna LIST) 
  Future<List<Insight>> getInsights() async {
    try {
      final List<dynamic> response = await _api.getList('/v1/financial-behavior/insights');
      return response.map((json) => Insight.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar insights: $e');
    }
  }

  /// Descarta um insight
  Future<void> dismissInsight(int insightId) async {
    try {
      await _api.delete('/v1/financial-behavior/insights/$insightId');
    } catch (e) {
      throw Exception('Erro ao descartar insight: $e');
    }
  }

  /// Busca perfil financeiro (retorna MAP)
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _api.getMap('/v1/financial-behavior/profile');
    } catch (e) {
      throw Exception('Erro ao buscar perfil: $e');
    }
  }

  /// Busca dashboard (retorna MAP)
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      return await _api.getMap('/v1/financial-behavior/dashboard');
    } catch (e) {
      throw Exception('Erro ao buscar dashboard: $e');
    }
  }

  /// Busca relatório mensal (retorna MAP)
  Future<Map<String, dynamic>> getMonthlyReport({int? year, int? month}) async {
    try {
      String url = '/v1/financial-behavior/reports/monthly';
      if (year != null && month != null) {
        url += '?year=$year&month=$month';
      }
      return await _api.getMap(url);
    } catch (e) {
      throw Exception('Erro ao buscar relatório mensal: $e');
    }
  }

  /// Busca categorias de gasto (retorna LIST)
  Future<List<Map<String, dynamic>>> getSpendingByCategory() async {
    try {
      final List<dynamic> response = await _api.getList('/v1/financial-behavior/reports/categories');
      return response.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }
}