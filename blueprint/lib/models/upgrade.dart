import 'dart:math';

enum UpgradeType { clickPower, passiveIncome, multiplier }

class Upgrade {
  final String id;
  final String name;
  final String description;
  final String icon;
  final UpgradeType type;
  final double value;
  final int baseCost;
  final double costMultiplier;
  final int maxLevel;
  final int cookiesRequiredToUnlock;
  int level;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.value,
    required this.baseCost,
    this.costMultiplier = 1.15,
    this.maxLevel = 50,
    this.cookiesRequiredToUnlock = 0,
    this.level = 0,
  });

  int get currentCost => (baseCost * pow(costMultiplier, level)).floor();

  bool get isMaxed => level >= maxLevel;

  double get totalValue {
    if (level == 0) return 0;
    switch (type) {
      case UpgradeType.clickPower:
      case UpgradeType.passiveIncome:
        return value * level;
      case UpgradeType.multiplier:
        return pow(value, level).toDouble();
    }
  }
}