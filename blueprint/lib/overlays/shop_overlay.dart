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
          color: Colors.brown.shade900.withOpacity(0.92),
          border: Border(
            left: BorderSide(color: Colors.brown.shade700, width: 2),
          ),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: widget.game.cookieNotifier,
          builder: (_, cookies, __) {
            final upgrades = widget.game.upgradeManager.all;
            final visible = upgrades
                .where((u) =>
            cookies >= u.cookiesRequiredToUnlock || u.level > 0)
                .toList();

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.brown.shade800,
                  child: const Center(
                    child: Text('UPGRADES',
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _UpgradeTile(
                      upgrade: visible[i],
                      canAfford: cookies >= visible[i].currentCost,
                      onBuy: () {
                        final bought = widget.game.upgradeManager.purchase(
                          visible[i].id,
                          widget.game.cookieNotifier,
                        );
                        if (bought) {
                          widget.game.saveToCloud();
                          setState(() {});
                        }
                      },
                    ),
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

class _UpgradeTile extends StatelessWidget {
  final Upgrade upgrade;
  final bool canAfford;
  final VoidCallback onBuy;

  const _UpgradeTile({
    required this.upgrade,
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
          color: Colors.brown.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canAfford && !isMaxed
                ? Colors.amber.withOpacity(0.6)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(upgrade.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(upgrade.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(
                    upgrade.description,
                    style: TextStyle(
                        color: Colors.brown.shade200, fontSize: 11),
                  ),
                  Text(
                    isMaxed
                        ? 'MAX (${upgrade.level}/${upgrade.maxLevel})'
                        : 'Lv ${upgrade.level}  •  🍪 ${_formatCost(upgrade.currentCost)}',
                    style: TextStyle(
                        color: isMaxed ? Colors.green : Colors.amber,
                        fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!isMaxed)
              GestureDetector(
                onTap: canAfford ? onBuy : null,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canAfford ? Colors.amber : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('BUY',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}