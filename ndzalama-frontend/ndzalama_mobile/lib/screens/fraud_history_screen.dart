import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';
import '../services/token_storage.dart';

import '../utils/auth_error_handler.dart';

class FraudHistoryScreen extends StatefulWidget {
  const FraudHistoryScreen({super.key});

  @override
  State<FraudHistoryScreen> createState() => _FraudHistoryScreenState();
}

class _FraudHistoryScreenState extends State<FraudHistoryScreen> {
  bool isLoading = true;
  List<dynamic> reports = [];

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/fraud/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

            if (response.statusCode == 200) {

        reports = jsonDecode(response.body);

      } else if (
          response.statusCode == 401 ||
          response.statusCode == 403
      ) {

        await AuthErrorHandler
            .handleUnauthorized(context);

        return;

      } else {

        showMessage(
          'Erro ao carregar histórico.',
        );
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

  Color riskColor(int score) {
    if (score >= 70) return Colors.redAccent;
    if (score >= 40) return Colors.orange;
    return green;
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
          'Histórico',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: green),
            )
          : RefreshIndicator(
              onRefresh: loadHistory,
              child: reports.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.history,
                          size: 72,
                          color: Colors.white30,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Ainda não existem análises no histórico.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];

                        final score = report['riskScore'] ?? 0;
                        final classification =
                            report['classification'] ?? 'DESCONHECIDO';
                        final sourceType = report['sourceType'] ?? '';
                        final content = report['content'] ?? '';
                        final advice = report['advice'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: riskColor(score).withOpacity(0.45),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        riskColor(score).withOpacity(0.16),
                                    child: Icon(
                                      score >= 70
                                          ? Icons.warning
                                          : Icons.shield,
                                      color: riskColor(score),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      classification,
                                      style: TextStyle(
                                        color: riskColor(score),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$score%',
                                    style: TextStyle(
                                      color: riskColor(score),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Text(
                                sourceType,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                content,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                advice,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}