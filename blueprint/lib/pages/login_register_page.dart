import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'two_factor.dart';
import '../services/email_2fa_service.dart';

import '../auth.dart';
import '../screens/main_menu_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool loading = false;

  String? errorMessage;

  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final TextEditingController controllerConfirmPassword = TextEditingController();

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    controllerConfirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final String email = controllerEmail.text.trim();
    final String password = controllerPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      if (isLogin) {
        await Auth().signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        final code = Email2FAService.generateCode();

        await Email2FAService.sendCode(
          email: email,
          code: code,
        );


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TwoFactorPage(correctCode: code),
          ),
        );
      } else {
        if (controllerConfirmPassword.text.trim() != password) {
          setState(() {
            errorMessage = 'Passwords do not match.';
            loading = false;
          });
          return;
        }
        await Auth().createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        setState(() {
          isLogin = true;
          loading = false;
          errorMessage = 'Account created! Please log in now.';
          controllerPassword.clear();
        });

        return;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Authentication failed.';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
      });
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.lightGreenAccent),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.green.shade900,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.lightGreenAccent,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade800.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.lightGreenAccent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🌸',
                    style: TextStyle(fontSize: 54),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    isLogin ? 'Welcome Back' : 'Create Account',
                    style: const TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isLogin
                        ? 'Log in to continue Garden Clicker'
                        : 'Register first, then log in',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  TextField(
                    controller: controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      label: 'Email',
                      icon: Icons.email,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: controllerPassword,
                    obscureText: !passwordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      label: 'Password',
                      icon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.lightGreenAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  if (!isLogin) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: controllerConfirmPassword,
                      obscureText: !confirmPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration(
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            confirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.lightGreenAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              confirmPasswordVisible = !confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],

                  if (errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: errorMessage!.contains('Account created')
                            ? Colors.lightGreenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.lightGreenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                        color: Colors.lightGreenAccent,
                      )
                          : Text(
                        isLogin ? 'Login' : 'Register',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                      setState(() {
                        isLogin = !isLogin;
                        errorMessage = null;
                        controllerPassword.clear();
                        controllerConfirmPassword.clear();
                      });
                    },
                    child: Text(
                      isLogin
                          ? 'Need an account? Register'
                          : 'Already have an account? Login',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainMenuScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Back to Main Menu',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}