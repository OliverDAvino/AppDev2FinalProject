import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cookie_game.dart';
import '../overlays/achievement_toast_overlay.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/shop_overlay.dart';
import 'achievements_screen.dart';
import 'rebirth_screen.dart';
import 'settings_screen.dart';
import '../pages/login_register_page.dart';
import '../widgets/garden_visuals.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CookieGame _game;
  bool _shopVisible = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _game = CookieGame();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await _game.saveToCloud();
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Garden Clicker',
                style: TextStyle(color: Colors.lightGreenAccent, fontSize: 18)),
            ValueListenableBuilder<int>(
              valueListenable: _game.rebirthManager.changeTick,
              builder: (_, __, ___) => ValueListenableBuilder<int>(
                valueListenable: _game.cookieNotifier,
                builder: (_, flowers, __) {
                  final gain = _game.rebirthManager.rebirthGain(flowers);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/RebirthEnergy.png',
                          width: 12, height: 12),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${_game.rebirthManager.rebirthEnergy} RE'
                          '${gain > 0 ? ' +$gain' : ''}',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
            icon: const Icon(Icons.emoji_events, color: Colors.amberAccent),
            tooltip: 'Achievements',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AchievementsScreen(
                  manager: _game.achievementManager,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
            tooltip: 'Rebirth',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RebirthScreen(game: _game)),
            ),
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
              MaterialPageRoute(builder: (_) => SettingsScreen(game: _game)),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic background + garden entities; rebuilt on upgrade changes.
          AnimatedBuilder(
            animation: Listenable.merge([
              _game.upgradeManager.changeTick,
              _game.rebirthManager.changeTick,
            ]),
            builder: (_, __) => GardenVisuals(manager: _game.upgradeManager),
          ),
          // Flame game (transparent background) sits on top of the garden visuals.
          GameWidget(
            game: _game,
            overlayBuilderMap: {
              'hud': (_, game) => HudOverlay(game: game as CookieGame),
              'shop': (_, game) => ShopOverlay(game: game as CookieGame),
            },
            initialActiveOverlays: const ['hud'],
          ),
          // Achievement toasts float above everything else.
          AchievementToastOverlay(manager: _game.achievementManager),
        ],
      ),
    );
  }
}
