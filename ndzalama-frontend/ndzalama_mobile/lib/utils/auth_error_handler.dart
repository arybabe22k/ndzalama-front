import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../services/token_storage.dart';

class AuthErrorHandler {
  static Future<void> handleUnauthorized(
    BuildContext context,
  ) async {
    await TokenStorage.clearToken();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sessão expirada. Faça login novamente.'),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}