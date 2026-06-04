import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ndzalama_mobile/screens/InsightsScreen.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Map<String, dynamic>? profile;

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/financial/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        profile = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String getProfileTypeName(String type) {
    switch (type) {
      case 'SAVER':
        return 'Poupador';
      case 'SPENDER':
        return 'Gastador';
      case 'BALANCED':
        return 'Equilibrado';
      case 'IMPULSIVE':
        return 'Impulsivo';
      case 'INVESTOR':
        return 'Investidor';
      default:
        return 'Em formação';
    }
  }

  Color getProfileColor(String type) {
    switch (type) {
      case 'SAVER':
        return green;
      case 'SPENDER':
        return orange;
      case 'BALANCED':
        return blue;
      case 'IMPULSIVE':
        return Colors.red;
      case 'INVESTOR':
        return Colors.purple;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileType = profile?['profileType'] ?? 'BALANCED';
    final profileName = getProfileTypeName(profileType);
    final profileColor = getProfileColor(profileType);
    final impulseTendency = (profile?['impulseTendency'] ?? 50).toInt();
    final financialDiscipline = (profile?['financialDiscipline'] ?? 50).toInt();
    final riskTolerance = (profile?['riskTolerance'] ?? 50).toInt();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Perfil Financeiro',
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
                  // Avatar e Perfil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [profileColor, profileColor.withOpacity(0.5)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profileName,
                          style: TextStyle(
                            color: profileColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Perfil Comportamental',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Métricas
                  Container(
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
                          'Métricas Comportamentais',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildMetricBar(
                          'Tendência a Impulso',
                          impulseTendency,
                          Colors.red,
                        ),
                        const SizedBox(height: 16),
                        _buildMetricBar(
                          'Disciplina Financeira',
                          financialDiscipline,
                          green,
                        ),
                        const SizedBox(height: 16),
                        _buildMetricBar(
                          'Tolerância a Risco',
                          riskTolerance,
                          blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Descrição do Perfil
                  Container(
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
                            Icon(Icons.info_outline, color: profileColor),
                            const SizedBox(width: 8),
                            Text(
                              'Sobre seu perfil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getProfileDescription(profileType, impulseTendency, financialDiscipline),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InsightsScreen(),
      ),
    );
  },   
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: blue.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: blue.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.insights,
          color: blue,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Ver Insights Financeiros',
          style: TextStyle(
            color: blue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 12),
                  // Botão Sair
                  GestureDetector(
                    onTap: logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Sair da Conta',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 6,
        ),
      ],
    );
  }

  String _getProfileDescription(String type, int impulse, int discipline) {
    switch (type) {
      case 'SAVER':
        return 'Você tem excelente disciplina financeira e consegue poupar uma parte significativa da sua renda. Continue assim! 💰';
      case 'SPENDER':
        return 'Seus gastos consomem a maior parte da sua renda. Considere criar um orçamento mensal para evitar apertos. 📊';
      case 'BALANCED':
        return 'Você tem um bom equilíbrio entre gastar e poupar. Mantenha o controle para não desbalancear. ⚖️';
      case 'IMPULSIVE':
        return 'Você tende a fazer compras não planejadas. Use a regra das 24 horas antes de comprar algo não essencial. 🛑';
      case 'INVESTOR':
        return 'Além de poupar, você busca fazer o dinheiro render. Continue estudando sobre investimentos! 📈';
      default:
        return 'Continue registrando suas transações para receber uma análise mais precisa do seu perfil financeiro. 📝';
    }
  }
}