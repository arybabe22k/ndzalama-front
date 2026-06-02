import 'dart:convert';
 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 
import '../services/api_client.dart';
import '../services/token_storage.dart';
import 'app_ui.dart';

import '../utils/auth_error_handler.dart';
 
class AnalyzeTextScreen extends StatefulWidget {
  const AnalyzeTextScreen({super.key});
 
  @override
  State<AnalyzeTextScreen> createState() => _AnalyzeTextScreenState();
}
 
class _AnalyzeTextScreenState extends State<AnalyzeTextScreen> {
  final _controller = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? result;
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  Future<void> analyzeText() async {
    if (_controller.text.trim().isEmpty) {
      _showMessage('Cole ou escreva a mensagem suspeita primeiro.');
      return;
    }
 
    setState(() {
      isLoading = true;
      result = null;
    });
 
    try {
      final token = await TokenStorage.getToken();
 
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/fraud/analyze-text'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sourceType': 'WHATSAPP',
          'content': _controller.text.trim(),
        }),
      );
 
      if (response.statusCode == 200) {
        setState(() => result = jsonDecode(response.body));
      } else {
        _showMessage('Erro ao analisar mensagem.');
      }
    } catch (e) {
      _showMessage('Erro de ligação ao servidor.');
    } finally {
      setState(() => isLoading = false);
    }
  }
 
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        backgroundColor: AppColors.surface,
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final riskScore = (result?['riskScore'] ?? 0) as int;
 
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar('Analisar Texto'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF448AFF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF448AFF).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF448AFF), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cole mensagens de WhatsApp, SMS ou email suspeito para análise.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.65),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 20),
 
            // Text input
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Cole aqui a mensagem suspeita...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),
            ),
 
            const SizedBox(height: 16),
 
            PrimaryButton(
              label: 'Analisar mensagem',
              onPressed: analyzeText,
              isLoading: isLoading,
              icon: Icons.search_rounded,
            ),
 
            if (result != null) ...[
              const SizedBox(height: 28),
 
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'RESULTADO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                ],
              ),
 
              const SizedBox(height: 20),
 
              RiskBadge(
                score: riskScore,
                classification: result!['classification'],
              ),
 
              const SizedBox(height: 16),
 
              DetectedSignalsList(signals: result!['detectedSignals']),
 
              const SizedBox(height: 16),
 
              AdviceCard(advice: result!['advice']),
 
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}