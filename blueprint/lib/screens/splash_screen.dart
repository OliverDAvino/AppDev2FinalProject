import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashApp(),
  ));
}

class SplashApp extends StatefulWidget {
  const SplashApp({super.key});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/temp.png', width: 100, height: 100),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Garden Clicker!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.lightGreenAccent,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.lightGreenAccent),
            const SizedBox(height: 10),
            const Text('Growing your garden...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
