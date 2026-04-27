import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cookie_game.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/shop_overlay.dart';
import 'settings_screen.dart';
import '../pages/login_register_page.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CookieGame _game;
  bool _shopVisible = false;

  @override
  void initState() {
    super.initState();
    _game = CookieGame();
  }

  void _toggleShop() {
    setState(() {
      _shopVisible = !_shopVisible;
      if (_shopVisible) {
        _game.overlays.add('shop');
      } else {
        _game.overlays.remove('shop');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        automaticallyImplyLeading: false,
        title: const Text('Garden Clicker', style: TextStyle(color: Colors.lightGreenAccent)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save',
            onPressed: () async {
              final isLoggedIn = FirebaseAuth.instance.currentUser != null;
              if (!isLoggedIn) {
                final goToLogin = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Sign in to Save'),
                    content: const Text(
                        'You need to be signed in to save your progress to the cloud. Sign in now?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
                if (goToLogin == true && mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
                return;
              }
              await _game.saveToCloud();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Game saved!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.upgrade,
              color: _shopVisible ? Colors.lightGreenAccent : Colors.white,
            ),
            tooltip: 'Upgrades',
            onPressed: _toggleShop,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'hud': (_, game) => HudOverlay(game: game as CookieGame),
          'shop': (_, game) => ShopOverlay(game: game as CookieGame),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
}
