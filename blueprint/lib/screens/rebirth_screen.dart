import 'package:flutter/material.dart';
import '../cookie_game.dart';
import '../models/rebirth_upgrade.dart';

class RebirthScreen extends StatefulWidget {
  final CookieGame game;
  const RebirthScreen({required this.game, super.key});

  @override
  State<RebirthScreen> createState() => _RebirthScreenState();
}

class _RebirthScreenState extends State<RebirthScreen> {
  String _formatNum(num n) {
    if (n >= 1e12) return '${(n / 1e12).toStringAsFixed(2)}T';
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  void _doRebirth() {
    final flowers = widget.game.cookieNotifier.value;
    final preview = widget.game.rebirthManager.rebirthGain(flowers);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rebirth?'),
        content: Text(
          'You will lose all flowers and shop upgrades, and gain $preview rebirth energy. Permanent upgrades are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.game.rebirthManager.performRebirth(
                widget.game.cookieNotifier,
                widget.game.upgradeManager,
              );
              widget.game.saveToCloud();
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Rebirth',
                style: TextStyle(color: Colors.deepPurpleAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rm = widget.game.rebirthManager;
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade800,
        title: const Text('Rebirth',
            style: TextStyle(color: Colors.amberAccent)),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: rm.changeTick,
        builder: (_, __, ___) {
          return ValueListenableBuilder<int>(
            valueListenable: widget.game.cookieNotifier,
            builder: (_, flowers, __) {
              final canRebirth = rm.canRebirth(flowers);
              final preview = rm.rebirthGain(flowers);
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.deepPurple.shade800,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/RebirthEnergy.png',
                                width: 28, height: 28),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatNum(rm.rebirthEnergy)} Rebirth Energy',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canRebirth
                              ? 'Rebirth now to gain +$preview energy'
                              : 'Need 1M flowers to rebirth (have ${_formatNum(flowers)})',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Rebirth Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                canRebirth ? Colors.amber : Colors.grey,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: canRebirth ? _doRebirth : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: rm.all.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final u = rm.all[i];
                        return _PermanentUpgradeTile(
                          upgrade: u,
                          canAfford: rm.rebirthEnergy >= u.currentCost,
                          onBuy: () {
                            final ok = rm.purchase(u.id);
                            if (ok) {
                              widget.game.saveToCloud();
                              setState(() {});
                            }
                          },
                          formatNum: _formatNum,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PermanentUpgradeTile extends StatelessWidget {
  final RebirthUpgrade upgrade;
  final bool canAfford;
  final VoidCallback onBuy;
  final String Function(num) formatNum;

  const _PermanentUpgradeTile({
    required this.upgrade,
    required this.canAfford,
    required this.onBuy,
    required this.formatNum,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxed = upgrade.isMaxed;
    final active = canAfford && !isMaxed;
    return Opacity(
      opacity: active ? 1.0 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade700,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? Colors.amberAccent : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            upgrade.icon.startsWith('assets/')
                ? SizedBox(
                    width: 36,
                    height: 36,
                    child: Image.asset(upgrade.icon, fit: BoxFit.contain),
                  )
                : Text(upgrade.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(upgrade.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text(upgrade.description,
                      style:
                          TextStyle(color: Colors.purple.shade100, fontSize: 12)),
                  const SizedBox(height: 4),
                  if (isMaxed)
                    Text(
                      'MAX (${upgrade.level}/${upgrade.maxLevel})',
                      style: const TextStyle(
                          color: Colors.greenAccent, fontSize: 12),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lv ${upgrade.level}/${upgrade.maxLevel}  •  ',
                          style: const TextStyle(
                              color: Colors.amberAccent, fontSize: 12),
                        ),
                        Image.asset('assets/images/RebirthEnergy.png',
                            width: 14, height: 14),
                        const SizedBox(width: 3),
                        Text(
                          formatNum(upgrade.currentCost),
                          style: const TextStyle(
                              color: Colors.amberAccent, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (!isMaxed)
              GestureDetector(
                onTap: canAfford ? onBuy : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford ? Colors.amberAccent : Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('BUY',
                      style: TextStyle(
                          fontSize: 12,
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
