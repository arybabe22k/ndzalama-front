import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_client.dart';
import '../services/token_storage.dart';

class QuizDetailScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;

  const QuizDetailScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool isLoading = false;
  int? selectedOptionId;
  Map<String, dynamic>? result;

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color purple = Color(0xFFB26DFF);
  static const Color green = Color(0xFF19A85B);

  Future<void> submitAnswer() async {
    if (selectedOptionId == null) {
      showMessage('Seleccione uma resposta.');
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/quizzes/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'questionId': widget.quiz['id'],
          'selectedOptionId': selectedOptionId,
        }),
      );

      if (response.statusCode == 200) {
        result = jsonDecode(response.body);
      } else {
        showMessage('Erro ao submeter resposta.');
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
    final options = widget.quiz['options'] as List<dynamic>;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Quiz',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionCard(),
            const SizedBox(height: 20),
            for (final option in options) _optionCard(option),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading || result != null ? null : submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Responder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            if (result != null) _resultCard(),
          ],
        ),
      ),
    );
  }

  Widget _questionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.quiz['category'] ?? 'Educação',
            style: const TextStyle(
              color: purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.quiz['question'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionCard(dynamic option) {
    final selected = selectedOptionId == option['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected ? purple.withOpacity(0.18) : card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? purple : Colors.white10,
        ),
      ),
      child: RadioListTile<int>(
        value: option['id'],
        groupValue: selectedOptionId,
        activeColor: purple,
        onChanged: result == null
            ? (value) {
                setState(() {
                  selectedOptionId = value;
                });
              }
            : null,
        title: Text(
          option['text'] ?? '',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _resultCard() {
    final correct = result!['correct'] == true;
    final color = correct ? green : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            correct ? 'Resposta correcta' : 'Resposta incorrecta',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result!['explanation'] ?? '',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pontos ganhos: ${result!['pointsEarned']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}