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

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    loadInsights();
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> dismissInsight(int insightId) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.delete(
        Uri.parse(
          '${ApiClient.baseUrl}/financial-behavior/insights/$insightId',
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
          : insights.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
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
                              'Impacto: ${insight['impactScore']}/100',
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
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white38,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum insight ainda',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre transações para receber\ninsights personalizados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
