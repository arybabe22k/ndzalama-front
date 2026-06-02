import 'dart:convert';
 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 
import '../services/api_client.dart';
import '../services/token_storage.dart';
import 'app_ui.dart';
 
 import '../utils/auth_error_handler.dart';
class AnalyzeUrlScreen extends StatefulWidget {
  const AnalyzeUrlScreen({super.key});
 
  @override
  State<AnalyzeUrlScreen> createState() => _AnalyzeUrlScreenState();
}
 
class _AnalyzeUrlScreenState extends State<AnalyzeUrlScreen> {
  final _urlController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? result;
 
  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
 
  Future<void> analyzeUrl() async {
    if (_urlController.text.trim().isEmpty) {
      _showMessage('Cole ou escreva um link primeiro.');
      return;
    }
 
    setState(() {
      isLoading = true;
      result = null;
    });
 
    try {
      final token = await TokenStorage.getToken();
 
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/fraud/analyze-url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'url': _urlController.text.trim()}),
      );
 
      if (response.statusCode == 200) {
        setState(() => result = jsonDecode(response.body));
      } else {
        _showMessage('Erro ao analisar link.');
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
      appBar: buildAppBar('Analisar Link'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: Color(0xFFFF5252), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nunca clique em links suspeitos. Cole-os aqui para verificar a segurança.',
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
 
            // URL input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Link suspeito',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'https://exemplo.com/...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
                    prefixIcon: const Icon(Icons.link_rounded, color: Colors.white38, size: 20),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
 
            const SizedBox(height: 16),
 
            PrimaryButton(
              label: 'Verificar link',
              onPressed: analyzeUrl,
              isLoading: isLoading,
              icon: Icons.security_rounded,
              color: const Color(0xFFFF5252),
            ),
 
            if (result != null) ...[
              const SizedBox(height: 28),
 
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