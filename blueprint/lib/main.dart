import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'cookie_game.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/shop_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CookieApp());
}

class CookieApp extends StatelessWidget {
  const CookieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookie Clicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: _GameScreen(),
    );
  }
}

class _GameScreen extends StatefulWidget {
  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  late final CookieGame _game;

  @override
  void initState() {
    super.initState();
    _game = CookieGame();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
      overlayBuilderMap: {
        'hud': (_, game) => HudOverlay(game: game as CookieGame),
        'shop': (_, game) => ShopOverlay(game: game as CookieGame),
      },
      initialActiveOverlays: const ['hud', 'shop'],
    );
  }
}