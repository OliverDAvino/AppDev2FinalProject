import 'package:flutter/material.dart';
import '../managers/achievement_manager.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  final AchievementManager manager;
  const AchievementsScreen({required this.manager, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text('Achievements',
            style: TextStyle(color: Colors.lightGreenAccent)),
        iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: manager.changeTick,
        builder: (_, __, ___) {
          final achievements = manager.all;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '$unlockedCount / ${achievements.length} Unlocked',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: achievements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) =>
                      _AchievementTile(achievement: achievements[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade800,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: unlocked ? Colors.lightGreenAccent : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(achievement.icon, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      color: unlocked ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: unlocked ? Colors.white70 : Colors.white38,
                      fontSize: 12,
                      fontStyle:
                          unlocked ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.check_circle,
                  color: Colors.lightGreenAccent, size: 20),
          ],
        ),
      ),
    );
  }
}
