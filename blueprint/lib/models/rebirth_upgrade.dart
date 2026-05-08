import 'dart:math';

class RebirthUpgrade {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int baseCost;
  final double costMultiplier;
  final int maxLevel;
  int level;

  RebirthUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.baseCost,
    required this.costMultiplier,
    required this.maxLevel,
    this.level = 0,
  });

  int get currentCost => (baseCost * pow(costMultiplier, level)).floor();

  bool get isMaxed => level >= maxLevel;
}
