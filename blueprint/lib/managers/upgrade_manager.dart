import 'package:flutter/foundation.dart';
import '../models/upgrade.dart';
import 'upgrade_definitions.dart';

class UpgradeManager {
  final Map<String, Upgrade> _upgrades = {
    for (var u in UpgradeDefinitions.all) u.id: u,
  };

  List<Upgrade> get all => _upgrades.values.toList();

  Upgrade get(String id) => _upgrades[id]!;

  // --- Computed stats ---

  int get clickPower {
    final base = _upgrades.values
        .where((u) => u.type == UpgradeType.clickPower)
        .fold(1, (sum, u) => sum + u.totalValue.toInt());
    return (base * globalMultiplier).floor();
  }

  double get cookiesPerSecond {
    final base = _upgrades.values
        .where((u) => u.type == UpgradeType.passiveIncome)
        .fold(0.0, (sum, u) => sum + u.totalValue);
    return base * globalMultiplier;
  }

  double get globalMultiplier {
    final multiplierUpgrades =
    _upgrades.values.where((u) => u.type == UpgradeType.multiplier);
    if (multiplierUpgrades.isEmpty) return 1.0;
    return multiplierUpgrades.fold(
        1.0, (product, u) => product * (u.level == 0 ? 1.0 : u.totalValue));
  }

  // --- Purchase logic ---

  bool purchase(String id, ValueNotifier<int> cookieNotifier) {
    final upgrade = _upgrades[id];
    if (upgrade == null) return false;
    if (upgrade.isMaxed) return false;
    if (cookieNotifier.value < upgrade.currentCost) return false;

    cookieNotifier.value -= upgrade.currentCost;
    upgrade.level++;
    return true;
  }

  // --- Serialization ---

  Map<String, dynamic> toJson() => {
    for (var u in _upgrades.values) u.id: u.level,
  };

  void fromJson(Map<String, dynamic> json) {
    for (var entry in json.entries) {
      if (_upgrades.containsKey(entry.key)) {
        _upgrades[entry.key]!.level = (entry.value as num).toInt();
      }
    }
  }
}