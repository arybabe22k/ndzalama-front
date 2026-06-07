import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';
import '../services/token_storage.dart';

import '../utils/auth_error_handler.dart';

class DailyTipScreen extends StatefulWidget {
  const DailyTipScreen({super.key});

  @override
  State<DailyTipScreen> createState() => _DailyTipScreenState();
}

class _DailyTipScreenState extends State<DailyTipScreen> {
  bool isLoading = true;
  Map<String, dynamic>? tip;

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);

  @override
  void initState() {
    super.initState();
    loadDailyTip();
  }

  Future<void> loadDailyTip() async {
    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/education/daily-tip'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        tip = jsonDecode(response.body);
      } else {
        showMessage('Erro ao carregar dica diária.');
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final title = tip?['title'] ?? 'Dica financeira';
    final content = tip?['message'] ?? 'Conteúdo da dica ainda não disponível.';
    final action = tip?['action'] ?? '';
    final category = tip?['category'] ?? 'Educação';
    
    return Scaffold(
      backgroundColor: bg, 
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dica diária', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: green))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: green.withOpacity(0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0x2219A85B),
                      child: Icon(Icons.lightbulb, color: green, size: 38),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      category,
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      content,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),

                    if (action.isNotEmpty) ...[
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0x2219A85B),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: green.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                action,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
