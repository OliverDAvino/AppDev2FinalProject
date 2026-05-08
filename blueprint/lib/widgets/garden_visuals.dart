import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../managers/upgrade_manager.dart';

// Renders the persistent garden background and animated entities (tulips,
// fountain, sakuras, sun) based on owned upgrade levels.
class GardenVisuals extends StatelessWidget {
  final UpgradeManager manager;
  const GardenVisuals({required this.manager, super.key});

  @override
  Widget build(BuildContext context) {
    final sunPower = manager.levelOf('double_batch');
    final darkSun = (manager.rebirthManager?.get('dark_sun_touch').level ?? 0) >= 1;
    final sunGif = darkSun
        ? 'assets/images/DarkSun.gif'
        : 'assets/images/Sun.gif';
    final tulipLevel = manager.levelOf('Tulip');
    final sakura = manager.levelOf('cookie_factory');
    final fountain = manager.levelOf('cookie_mine');

    final background = sunPower >= 1
        ? (darkSun
            ? 'assets/images/DarkBackground.png'
            : 'assets/images/SunBackground.png')
        : 'assets/images/MainBackground.png';

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(background, fit: BoxFit.cover),
              ),

              if (sunPower >= 1)
                Positioned(
                  top: h * 0.02,
                  left: w / 2 - 60,
                  width: 120,
                  height: 120,
                  child: Image.asset(sunGif, fit: BoxFit.contain),
                ),

              if (sakura >= 1)
                Positioned(
                  top: h * 0.05,
                  left: w * 0.0 -4,
                  width: 280,
                  height: 400,
                  child: Image.asset('assets/images/Sakura.gif',
                      fit: BoxFit.contain),
                ),

              if (sakura >= 25)
                Positioned(
                  top: h * 0.2,
                  right: w * 0.0-4,
                  width: 260,
                  height: 300,
                  child: Transform.flip(
                    flipX: true,
                    child: Image.asset('assets/images/Sakura.gif',
                        fit: BoxFit.contain),
                  ),
                ),

              if (fountain >= 1)
                Positioned(
                  left: w / 2 - 105,
                  bottom: 100,
                  width: 210,
                  height: 210,
                  child: Image.asset('assets/images/Fountain.gif',
                      fit: BoxFit.contain),
                ),

              ..._buildTulips(tulipLevel, w, h),
            ],
          );
        },
      ),
    );
  }

  // 1 purchased -> 1 tulip; otherwise one tulip per 10 purchased.
  int _visibleTulipCount(int level) {
    if (level <= 0) return 0;
    if (level < 10) return 1;
    return level ~/ 10;
  }

  List<Widget> _buildTulips(int level, double w, double h) {
    final count = _visibleTulipCount(level);
    if (count == 0) return const [];
    const tulipSize = 56.0;
    // Layout along the bottom grass band; deterministic pseudo-random offsets
    // keep placement stable across rebuilds and saves.
    final rand = math.Random(42);
    final widgets = <Widget>[];
    final usableWidth = w - tulipSize;
    for (var i = 0; i < count; i++) {
      final xFrac = count == 1 ? 0.5 : i / (count - 1);
      final jitterX = (rand.nextDouble() - 0.5) * (usableWidth / count) * 0.3;
      final jitterY = rand.nextDouble() * 24.0;
      final left = (usableWidth * xFrac) + jitterX;
      widgets.add(Positioned(
        left: left.clamp(0.0, usableWidth),
        bottom: 24.0 + jitterY,
        width: tulipSize,
        height: tulipSize,
        child: Image.asset('assets/images/Tulip.png', fit: BoxFit.contain),
      ));
    }
    return widgets;
  }
}
