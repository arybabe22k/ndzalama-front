import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/token_storage.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final phoneController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading = false;

  static const Color background =
      Color(0xFF071A12);

  static const Color card =
      Color(0xFF10291D);

  static const Color green =
      Color(0xFF19A85B);

  static const Color greenDark =
      Color(0xFF0B7A3B);

  @override
  void dispose() {

    phoneController.dispose();

    passwordController.dispose();

    super.dispose();
  }

  Future<void> login() async {

    if (phoneController.text
            .trim()
            .isEmpty ||
        passwordController.text
            .trim()
            .isEmpty) {

      showMessage(
        'Preencha telefone e palavra-passe.',
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final response =
        await AuthService().login(
      phone:
          phoneController.text
              .trim(),

      password:
          passwordController.text
              .trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (response != null) {

      await TokenStorage.saveToken(
        response['accessToken'],
      );

      await TokenStorage.saveUserName(
        response['name'],
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (_) =>
              const MainNavigationScreen(),
        ),
      );

    } else {

      showMessage(
        'Credenciais inválidas.',
      );
    }
  }

  void showMessage(
      String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          background,

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            24,
          ),

          child: SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height -
                    48,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                const SizedBox(
                  height: 30,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .all(18),

                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        greenDark,
                        green,
                      ],
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      26,
                    ),

                    boxShadow: [

                      BoxShadow(
                        color: green
                            .withOpacity(
                          0.25,
                        ),

                        blurRadius:
                            24,

                        offset:
                            const Offset(
                          0,
                          12,
                        ),
                      ),
                    ],
                  ),

                  child:
                      const Icon(
                    Icons.shield,
                    size: 62,
                    color:
                        Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                const Text(
                  'Ndzalama IA',

                  style: TextStyle(
                    color:
                        Colors.white,

                    fontSize: 38,

                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Protecção financeira inteligente contra fraudes digitais.',

                  style: TextStyle(
                    color:
                        Colors.white70,

                    fontSize: 16,

                    height: 1.4,
                  ),
                ),

                const SizedBox(
                  height: 42,
                ),

                _inputField(
                  controller:
                      phoneController,

                  label:
                      'Telefone',

                  icon:
                      Icons.phone,

                  keyboardType:
                      TextInputType
                          .phone,
                ),

                const SizedBox(
                  height: 18,
                ),

                _inputField(
                  controller:
                      passwordController,

                  label:
                      'Palavra-passe',

                  icon:
                      Icons.lock,

                  obscureText:
                      true,
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  height: 58,

                  child:
                      ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : login,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          green,

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                    ),

                    child: isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors.white,
                          )

                        : const Text(
                            'Entrar',

                            style:
                                TextStyle(
                              fontSize:
                                  18,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Center(
                  child: TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      'Criar conta',

                      style: TextStyle(
                        color:
                            green,

                        fontSize: 15,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Center(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          card,

                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),

                      border: Border.all(
                        color:
                            Colors.white10,
                      ),
                    ),

                    child: const Text(
                      'Detecte burlas antes que elas aconteçam.',

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color:
                            Colors.white70,

                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({

    required TextEditingController
        controller,

    required String label,

    required IconData icon,

    TextInputType?
        keyboardType,

    bool obscureText = false,

  }) {

    return Container(
      decoration: BoxDecoration(
        color: card,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: TextField(
        controller: controller,

        keyboardType:
            keyboardType,

        obscureText:
            obscureText,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration:
            InputDecoration(
          labelText:
              label,

          labelStyle:
              const TextStyle(
            color:
                Colors.white60,
          ),

          prefixIcon:
              Icon(
            icon,
            color:
                green,
          ),

          border:
              InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}