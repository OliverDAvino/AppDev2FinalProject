import 'package:flutter/material.dart';
import '../cookie_game.dart';

class HudOverlay extends StatelessWidget {
  final CookieGame game;
  const HudOverlay({required this.game, super.key});

  String _format(int n) {
    if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(1)}B';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder<int>(
          valueListenable: game.cookieNotifier,
          builder: (_, flowers, __) {
            final fps = game.upgradeManager.cookiesPerSecond;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🌸 ${_format(flowers)}',
                  style: const TextStyle(
                    color: Colors.lightGreenAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
                if (fps > 0)
                  Text(
                    'per second: ${fps.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
