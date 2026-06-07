import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';
import '../services/token_storage.dart';
import '../utils/auth_error_handler.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  bool isLoading = true;
  bool isCheckingIn = false;

  Map<String, dynamic>? streak;

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);

  @override
  void initState() {
    super.initState();
    loadStreak();
  }

  Future<void> loadStreak() async {
    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/gamification/streak'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        streak = jsonDecode(response.body);
      } else if ( 
          response.statusCode == 401 ||
          response.statusCode == 403
      ) {
        await AuthErrorHandler.handleUnauthorized(context);
        return;
      } else {
        showMessage('Erro ao carregar streak.');
      }
    } catch (e) {
      showMessage('Erro de ligação.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkIn() async {
    setState(() {
      isCheckingIn = true;
    });

    try {
      final token = await TokenStorage.getToken();
  
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/gamification/check-in'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        streak = jsonDecode(response.body);

        showMessage('Check-in diário realizado!');
      } else if (
          response.statusCode == 401 ||
          response.statusCode == 403
      ) {
        await AuthErrorHandler.handleUnauthorized(context);
        return;
      } else {
        showMessage('Erro ao fazer check-in.');
      }
    } catch (e) {
      showMessage('Erro de ligação.');
    } finally {
      setState(() {
        isCheckingIn = false;
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
    final currentStreak =
        streak?['currentStreak'] ?? 0;

    final longestStreak =
        streak?['longestStreak'] ?? 0;

    final checkedInToday =
        streak?['checkedInToday'] ?? false;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white),
        title: const Text(
          'Daily Streak',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius:
                          BorderRadius.circular(28),
                      border:
                          Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 82,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          '$currentStreak dias',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Sequência actual',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _stat(
                              'Maior streak',
                              '$longestStreak',
                            ),
                            _stat(
                              'Hoje',
                              checkedInToday
                                  ? 'Feito'
                                  : 'Pendente',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed:
                          checkedInToday || isCheckingIn
                              ? null
                              : checkIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                      child: isCheckingIn
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              checkedInToday
                                  ? 'Check-in realizado'
                                  : 'Fazer check-in diário',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}