import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String baseUrl = 'http://10.0.2.2:8081/api';

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Envia mensagem e recebe resposta (modo síncrono) - retorna String
  Future<String> sendMessage(String message, {String? sessionId}) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/v1/ai-chat/send'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'sessionId': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao enviar mensagem: $e');
    }
  }

  /// Envia mensagem com streaming (Server-Sent Events)
  Stream<String> sendMessageStream(String message, {String? sessionId}) async* {
    try {
      final token = await _getAuthToken();
      
      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl/v1/ai-chat/send-stream'),
      );
      
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.body = jsonEncode({
        'message': message,
        'sessionId': sessionId,
      });
      
      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode == 200) {
        await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (var line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              if (data != '[DONE]' && data.isNotEmpty) {
                yield data;
              }
            }
          }
        }
      } else {
        throw Exception('Erro no streaming: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha no streaming: $e');
    }
  }

  /// Chat financeiro especializado - retorna String
  Future<String> financialChat(String message) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/v1/ai-chat/financial'),
        headers: headers,
        body: message,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha no chat financeiro: $e');
    }
  }
}