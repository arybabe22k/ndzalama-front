import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';

import '../utils/auth_error_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Map<String, dynamic>? profile;
  List<dynamic> achievements = [];
  String userName = '';

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);
  static const Color greenDark = Color(0xFF0B7A3B);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final token = await TokenStorage.getToken();
      final name = await TokenStorage.getUserName();

      userName = name ?? '';

      final profileResponse = await http.get(
        Uri.parse('${ApiClient.baseUrl}/gamification/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final achievementsResponse = await http.get(
        Uri.parse('${ApiClient.baseUrl}/gamification/achievements'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (profileResponse.statusCode == 200) {
        profile = jsonDecode(profileResponse.body);
      }

      if (achievementsResponse.statusCode == 200) {
        achievements = jsonDecode(achievementsResponse.body);
      }
    } catch (e) {
      showMessage('Erro ao carregar perfil.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = profile?['level'] ?? 0;
    final points = profile?['points'] ?? 0;
    final progress = profile?['progress'] ?? 0;
    final nextLevelPoints = profile?['nextLevelPoints'] ?? 0;
    final streakDays = profile?['streakDays'] ?? 0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: green))
          : RefreshIndicator(
              onRefresh: loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _header(level, points),
                    const SizedBox(height: 20),
                    _progressCard(progress, nextLevelPoints, streakDays),
                    const SizedBox(height: 24),
                    _sectionTitle('Conquistas'),
                    const SizedBox(height: 12),
                    if (achievements.isEmpty)
                      _emptyState()
                    else
                      for (final achievement in achievements)
                        _achievementCard(achievement),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _header(int level, int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [greenDark, green],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: green.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 52,
              color: greenDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            userName.isEmpty ? 'Utilizador' : userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nível $level • $points pontos',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(int progress, int nextLevelPoints, int streakDays) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _statRow(Icons.trending_up, 'Progresso', '$progress%', green),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: (progress / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.white12,
            color: green,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 18),
          _statRow(Icons.flag, 'Próximo nível', '$nextLevelPoints pontos', Colors.blue),
          const SizedBox(height: 12),
          _statRow(Icons.local_fire_department, 'Sequência diária', '$streakDays dias', Colors.orange),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.16),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: const Text(
        'Ainda não tens conquistas. Continua a analisar fraudes e responder quizzes.',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _achievementCard(dynamic achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFFF3CD),
            child: Icon(Icons.emoji_events, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] ?? 'Conquista',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}