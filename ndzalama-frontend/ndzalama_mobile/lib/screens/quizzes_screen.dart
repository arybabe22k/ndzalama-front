import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';
import '../services/token_storage.dart';
import 'quiz_detail_screen.dart';

import '../utils/auth_error_handler.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  bool isLoading = true;
  List<dynamic> quizzes = [];

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color purple = Color(0xFFB26DFF);

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/quizzes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        quizzes = jsonDecode(response.body);
      } else {
        showMessage('Erro ao carregar quizzes.');
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
          'Quizzes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: purple))
          : quizzes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum quiz disponível.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0x22B26DFF),
                            child: Icon(Icons.quiz, color: purple),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz['question'] ?? 'Quiz',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  quiz['category'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizDetailScreen(quiz: quiz),
                                ),
                              );
                            },
                            child: const Text('Abrir'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}