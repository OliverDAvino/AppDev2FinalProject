import 'package:flutter/material.dart';
import '../cookie_game.dart';
import '../models/upgrade.dart';

class ShopOverlay extends StatefulWidget {
  final CookieGame game;
  const ShopOverlay({required this.game, super.key});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 220,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green.shade900.withOpacity(0.92),
          border: Border(
            left: BorderSide(color: Colors.green.shade700, width: 2),
          ),
        ),
        child: ValueListenableBuilder<int>(
          // Rebuild when rebirth state (Flash Sale discount) changes too.
          valueListenable: widget.game.rebirthManager.changeTick,
          builder: (_, __, ___) => ValueListenableBuilder<int>(
          valueListenable: widget.game.cookieNotifier,
          builder: (_, flowers, __) {
            final manager = widget.game.upgradeManager;
            final upgrades = manager.all;
            final visible = upgrades
                .where((u) =>
                    flowers >= u.cookiesRequiredToUnlock || u.level > 0)
                .toList();

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.green.shade800,
                  child: const Center(
                    child: Text('UPGRADES',
                        style: TextStyle(
                            color: Colors.lightGreenAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final cost = manager.discountedCost(visible[i]);
                      return _UpgradeTile(
                        upgrade: visible[i],
                        cost: cost,
                        canAfford: flowers >= cost,
                        onBuy: () {
                          final id = visible[i].id;
                          final bought = manager.purchase(
                            id,
                            widget.game.cookieNotifier,
                          );
                          if (bought) {
                            widget.game.achievementManager.checkUpgrade(
                              id,
                              manager.levelOf(id),
                            );
                            widget.game.saveToCloud();
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          ),
        ),
      ),
    );
  }
}

class _UpgradeTile extends StatelessWidget {
  final Upgrade upgrade;
  final int cost;
  final bool canAfford;
  final VoidCallback onBuy;

  const _UpgradeTile({
    required this.upgrade,
    required this.cost,
    required this.canAfford,
    required this.onBuy,
  });

  String _formatCost(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isMaxed = upgrade.isMaxed;
    return Opacity(
      opacity: (canAfford && !isMaxed) ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canAfford && !isMaxed
                ? Colors.lightGreenAccent.withOpacity(0.6)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            _UpgradeIcon(icon: upgrade.icon),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(upgrade.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(
                    upgrade.description,
                    style: TextStyle(color: Colors.green.shade200, fontSize: 11),
                  ),
                  Text(
                    isMaxed
                        ? 'MAX (${upgrade.level}/${upgrade.maxLevel})'
                        : 'Lv ${upgrade.level}  •  🌸 ${_formatCost(cost)}',
                    style: TextStyle(
                        color: isMaxed ? Colors.greenAccent : Colors.lightGreenAccent,
                        fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!isMaxed)
              GestureDetector(
                onTap: canAfford ? onBuy : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canAfford ? Colors.lightGreenAccent : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('BUY',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeIcon extends StatelessWidget {
  final String icon;
  const _UpgradeIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon.startsWith('assets/')) {
      // Click-power touch icons render larger per design.
      const touchIcons = {
        'assets/images/GrassTouch.png',
        'assets/images/WaterTouch.png',
        'assets/images/SunTouch.png',
      };
      final size = touchIcons.contains(icon) ? 36.4 : 28.0;
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(icon, fit: BoxFit.contain),
      );
    }
    return Text(icon, style: const TextStyle(fontSize: 24));
  }
}
