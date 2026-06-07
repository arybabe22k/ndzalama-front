import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_client.dart';
import '../services/token_storage.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool isLoading = true;
  List<dynamic> insights = [];
  Map<String, dynamic>? healthReport;
  Map<String, dynamic>? dashboard;

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadInsights(),
      loadHealthReport(),
      loadDashboard(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadInsights() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/financial/insights'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        insights = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao carregar insights: $e');
    }
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
        Uri.parse('${ApiClient.baseUrl}/financial/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        dashboard = jsonDecode(response.body);
      } 
    } catch (e) {
      debugPrint('Erro ao carregar dashboard: $e');
    }
  }

  Future<void> dismissInsight(int insightId) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.delete(
        Uri.parse(
          '${ApiClient.baseUrl}/financial/insights/$insightId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() { 
          insights.removeWhere((i) => i['id'] == insightId);
        });
      }
    } catch (e) {
      debugPrint('Erro ao descartar insight: $e');
    }
  }

  Color getInsightColor(String type) {
    switch (type) {
      case 'WARNING':
        return red;
      case 'OPPORTUNITY':
        return green;
      case 'TIP':
        return blue;
      case 'ACHIEVEMENT':
        return orange;
      default:
        return Colors.white54;
    }
  }

  IconData getInsightIcon(String type) {
    switch (type) {
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'OPPORTUNITY':
        return Icons.trending_up;
      case 'TIP':
        return Icons.lightbulb_outline;
      case 'ACHIEVEMENT':
        return Icons.emoji_events;
      default:
        return Icons.info_outline;
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
          'Insights Financeiros', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Dashboard integrado
                  _buildHealthScoreCard(),
                  const SizedBox(height: 20),
                  _buildFinancialSummary(),
                  const SizedBox(height: 20),
                  _buildRiskFactors(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  
                  // Seção de Insights
                  _buildInsightsHeader(),
                  const SizedBox(height: 12),
                  insights.isEmpty
                      ? _buildEmptyInsights()
                      : _buildInsightsList(),
                ],
              ),
            ),
    );
  }

  // ========== MÉTODOS DO DASHBOARD ==========

  Widget _buildHealthScoreCard() {
    final score = healthReport?['healthScore'] ?? dashboard?['healthScore'] ?? 0;
    final classification = healthReport?['healthClassification'] ?? dashboard?['healthClassification'] ?? 'CRÍTICA';
    final savingsRate = (healthReport?['savingsRate'] ?? dashboard?['savingsRate'] ?? 0).toDouble();
    final impulseRate = (dashboard?['impulsePurchaseRate'] ?? 0).toDouble();
    final behavioralProfile = dashboard?['behavioralProfile'] ?? 'IMPULSIVE';

    Color getColor() {
      if (score >= 80) return green;
      if (score >= 60) return blue;
      if (score >= 40) return orange;
      return red;
    }

    String getAlertMessage() {
      if (score < 30) {
        return '⚠️ Situação CRÍTICA - Ação imediata necessária!';
      }
      if (score < 60) {
        return '⚠️ Atenção - Sua saúde financeira precisa de cuidados';
      }
      return '✅ Você está no caminho certo!';
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    getAlertMessage(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Poupança', '${savingsRate.toStringAsFixed(1)}%', 
                  savingsRate > 0 ? green : red),
              _buildMetric('Impulso', '${impulseRate.toStringAsFixed(1)}%', 
                  impulseRate < 30 ? green : orange),
              _buildMetric('Perfil', behavioralProfile.substring(0, 3), blue),
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
    final totalIncomes = dashboard?['monthlyIncomes'] ?? 0;
    final totalExpenses = dashboard?['monthlyExpenses'] ?? 0;
    final balance = dashboard?['monthlyBalance'] ?? 0.0;

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
                  totalIncomes > 0 ? green : Colors.grey,
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
          if (totalIncomes == 0 && totalExpenses > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ Sem receitas registradas neste mês',
                      style: TextStyle(
                        color: orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          textAlign: TextAlign.center,
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

  Widget _buildRiskFactors() {
    final riskFactors = dashboard?['topRiskFactors'] as List? ?? [];
    
    if (riskFactors.isEmpty) return const SizedBox.shrink();
    
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
            children: [
              Icon(Icons.warning_rounded, color: red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pontos de Atenção Urgentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...riskFactors.map((risk) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: red, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      risk.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
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
            'Ações Recomendadas',
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
                  'Registrar Renda',
                  Icons.attach_money,
                  green,
                  () {
                    // Navegar para registrar renda
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Reduzir Gastos',
                  Icons.trending_down,
                  orange,
                  () {
                    // Navegar para análise de gastos
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Plano Urgente',
                  Icons.emergency,
                  red,
                  () {
                    // Navegar para plano de recuperação
                  },
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

  // ========== MÉTODOS DOS INSIGHTS ==========

  Widget _buildInsightsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '🎯 Insights Personalizados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${insights.length} ${insights.length == 1 ? 'insight' : 'insights'}',
            style: TextStyle(
              color: green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        final type = insight['insightType'] ?? 'TIP';
        final color = getInsightColor(type);
        final icon = getInsightIcon(type);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight['title'] ?? 'Insight',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => dismissInsight(insight['id']),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insight['description'] ?? '',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (insight['impactScore'] != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Prioridade: ${insight['impactScore']}/100',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyInsights() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.white.withOpacity(0.2),
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum insight disponível',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre mais transações para\nreceber recomendações personalizadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}