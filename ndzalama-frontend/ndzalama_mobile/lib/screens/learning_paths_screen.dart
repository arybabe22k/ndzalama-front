import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';
import '../services/token_storage.dart';

import '../utils/auth_error_handler.dart';

class LearningPathsScreen extends StatefulWidget {
  const LearningPathsScreen({super.key});

  @override
  State<LearningPathsScreen> createState() => _LearningPathsScreenState();
}

class _LearningPathsScreenState extends State<LearningPathsScreen> {
  bool isLoading = true;
  List<dynamic> learningPaths = [];

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);

  @override
  void initState() {
    super.initState();
    loadLearningPaths();
  }

  Future<void> loadLearningPaths() async {
    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/education/learning-paths'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        learningPaths = jsonDecode(response.body);
      } else {
        showMessage('Erro ao carregar learning paths.');
      }
    } catch (e) {
      showMessage('Erro de ligação ao servidor.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Learning Paths',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: green))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: learningPaths.length,
              itemBuilder: (context, index) {
                final path = learningPaths[index];
                final unlocked = path['unlocked'] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: unlocked ? green.withOpacity(0.45) : Colors.white10,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: unlocked
                            ? green.withOpacity(0.16)
                            : Colors.red.withOpacity(0.16),
                        child: Icon(
                          unlocked ? Icons.lock_open : Icons.lock,
                          color: unlocked ? green : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              path['title'] ?? 'Learning Path',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              path['description'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _pill('Nível ${path['level']}', Colors.blue),
                                _pill('${path['requiredPoints']} pontos', green),
                                _pill(unlocked ? 'Desbloqueado' : 'Bloqueado',
                                    unlocked ? green : Colors.redAccent),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}