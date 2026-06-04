import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_client.dart';
import '../services/token_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  Map<String, dynamic>? healthReport;
  Map<String, dynamic>? dashboard;

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      loadHealthReport(),
      loadDashboard(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadHealthReport() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/financial/health-report'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        healthReport = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao carregar health report: $e');
    }
  }

  Future<void> loadDashboard() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/financial-behavior/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        dashboard = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao carregar dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: green),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHealthScoreCard(),
                  const SizedBox(height: 20),
                  _buildFinancialSummary(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildRecentInsights(),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthScoreCard() {
    final score = healthReport?['healthScore'] ?? 0;
    final classification = healthReport?['healthClassification'] ?? 'REGULAR';
    final colorCode = healthReport?['colorCode'] ?? '#F59E0B';
    final savingsRate = (healthReport?['savingsRate'] ?? 0).toDouble();

    Color getColor() {
      switch (classification) {
        case 'EXCELENTE':
          return green;
        case 'BOA':
          return blue;
        case 'REGULAR':
          return orange;
        default:
          return red;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: getColor().withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saúde Financeira',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      classification,
                      style: TextStyle(
                        color: getColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getColor().withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      color: getColor(),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(getColor()),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(
                'Poupança',
                '${savingsRate.toStringAsFixed(1)}%',
                green,
              ),
              _buildMetric(
                'Risco',
                '${100 - score}%',
                red,
              ),
              _buildMetric(
                'Disciplina',
                '${score}%',
                blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
    final totalIncomes = dashboard?['totalIncomes'] ?? 0;
    final totalExpenses = dashboard?['totalExpenses'] ?? 0;
    final balance = (totalIncomes - totalExpenses).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Mês',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Receitas',
                  'MT ${totalIncomes.toStringAsFixed(2)}',
                  Icons.arrow_upward,
                  green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Despesas',
                  'MT ${totalExpenses.toStringAsFixed(2)}',
                  Icons.arrow_downward,
                  red,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Saldo',
                  'MT ${balance.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  balance >= 0 ? green : red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Nova Transação',
                  Icons.add_circle_outline,
                  green,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Scanear',
                  Icons.scanner,
                  blue,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Chat IA',
                  Icons.chat_bubble_outline,
                  orange,
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInsights() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '💡 Insights Recentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver todos',
                  style: TextStyle(color: green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x2219A85B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: green.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Continue assim! Sua taxa de poupança está acima da média.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
