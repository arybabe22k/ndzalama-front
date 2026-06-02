import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/token_storage.dart';

void main() {
  runApp(const NdzalamaApp());
}

class NdzalamaApp extends StatelessWidget {
  const NdzalamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ndzalama IA',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  Future<void> checkToken() async {
    final token = await TokenStorage.getToken();

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return isLoggedIn
        ? const MainNavigationScreen()
        : const LoginScreen();
  }
}