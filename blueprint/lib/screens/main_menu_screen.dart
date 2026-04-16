import 'package:flutter/material.dart';

void main(){
  runApp(MainMenu());
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Row(
          children: [
            Text("Title")
          ],
        ),
      ),
    );
  }
}
