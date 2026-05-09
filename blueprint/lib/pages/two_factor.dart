import 'package:flutter/material.dart';
import '../screens/main_menu_screen.dart';

class TwoFactorPage extends StatefulWidget {
  final String correctCode;

  const TwoFactorPage({
    super.key,
    required this.correctCode,
  });

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final TextEditingController codeController = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void verifyCode() {
    if (codeController.text.trim() == widget.correctCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainMenuScreen(),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Incorrect code. Please check your email.';
      });
    }
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
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.lightGreenAccent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.email,
                    color: Colors.lightGreenAccent,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email Verification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enter the 6-digit code sent to your email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Verification Code',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.password,
                        color: Colors.lightGreenAccent,
                      ),
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
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.lightGreenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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