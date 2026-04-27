import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CookieApp());
}

class CookieApp extends StatelessWidget {
  const CookieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden Clicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashApp(),
    );
  }
}
