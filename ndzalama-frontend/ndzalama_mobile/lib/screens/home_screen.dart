import 'package:flutter/material.dart';
import 'package:ndzalama_mobile/screens/add_transaction_screen.dart';
import 'package:ndzalama_mobile/screens/transactions_screen.dart';

import '../services/token_storage.dart';
import 'analyze_text_screen.dart';
import 'analyze_image_screen.dart';
import 'analyze_url_screen.dart';
import 'daily_tip_screen.dart';
import 'learning_paths_screen.dart';
import 'quizzes_screen.dart';
import 'profile_screen.dart';
import 'fraud_history_screen.dart';
import 'streak_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final name = await TokenStorage.getUserName();

    setState(() {
      userName = name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071A12),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              _riskCard(),
              const SizedBox(height: 16),
              _buildAnalyzeCard(), // Card de análise de transação
              const SizedBox(height: 24),
              const Text(
                'Scanner antifraude',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _scannerGrid(context),
              const SizedBox(height: 24),
              const Text(
                'Educação financeira',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _educationGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0x2219A85B),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.shield,
            color: Color(0xFF19A85B),
            size: 34,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isEmpty
                    ? 'Ndzalama IA'
                    : 'Bem-vindo, $userName 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Protecção financeira inteligente',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B7A3B),
            Color(0xFF19A85B),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF19A85B).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proteja-se contra burlas digitais',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Analise mensagens, imagens e links suspeitos antes de agir.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scannerGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _actionCard(
          title: 'Texto',
          icon: Icons.text_fields,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnalyzeTextScreen(),
              ),
            );
          },
        ),
        _actionCard(
          title: 'Imagem',
          icon: Icons.image_search,
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnalyzeImageScreen(),
              ),
            );
          },
        ),
        _actionCard(
          title: 'Link',
          icon: Icons.link,
          color: Colors.redAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnalyzeUrlScreen(),
              ),
            );
          },
        ),
        _actionCard(
          title: 'Transação',
          icon: Icons.payment,
          color: const Color(0xFF19A85B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionsScreen(),
              ),
            );
          },
        ),
        _actionCard(
          title: 'Histórico',
          icon: Icons.history,
          color: Colors.cyan,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FraudHistoryScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _educationGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        _wideCard(
          title: 'Dica diária',
          subtitle: 'Aprenda todos os dias',
          icon: Icons.lightbulb,
          color: const Color(0xFF19A85B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DailyTipScreen(),
              ),
            );
          },
        ),
        _wideCard(
          title: 'Quizzes',
          subtitle: 'Teste o seu conhecimento',
          icon: Icons.quiz,
          color: Colors.purpleAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QuizzesScreen(),
              ),
            );
          },
        ),
        _wideCard(
          title: 'Learning Paths',
          subtitle: 'Evolua por níveis',
          icon: Icons.school,
          color: Colors.tealAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LearningPathsScreen(),
              ),
            );
          },
        ),
        _wideCard(
          title: 'Daily Streak',
          subtitle: 'Mantenha a sequência',
          icon: Icons.local_fire_department,
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StreakScreen(),
              ),
            );
          },
        ),
        _wideCard(
          title: 'Perfil',
          subtitle: 'Pontos e conquistas',
          icon: Icons.person,
          color: Colors.indigoAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _actionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10291D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 38),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wideCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10291D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 34),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B7A3B),
            Color(0xFF19A85B),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF19A85B).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisar Transação',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Receba uma análise inteligente da IA em tempo real',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
