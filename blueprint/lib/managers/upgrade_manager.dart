import 'package:flutter/foundation.dart';
import '../models/upgrade.dart';
import 'rebirth_manager.dart';
import 'upgrade_definitions.dart';

class UpgradeManager {
  final Map<String, Upgrade> _upgrades = {
    for (var u in UpgradeDefinitions.all) u.id: u,
  };

  // Increments whenever upgrade levels change so listeners (game UI) can rebuild.
  final ValueNotifier<int> changeTick = ValueNotifier<int>(0);

  // Optional rebirth manager; injected by CookieGame after construction.
  // When set, rebirth multipliers and discounts apply to derived stats.
  RebirthManager? rebirthManager;

  List<Upgrade> get all => _upgrades.values.toList();

  Upgrade get(String id) => _upgrades[id]!;

  int levelOf(String id) => _upgrades[id]?.level ?? 0;

  // --- Computed stats ---

  int get clickPower {
    final base = _upgrades.values
        .where((u) => u.type == UpgradeType.clickPower)
        .fold(1, (sum, u) => sum + u.totalValue.toInt());
    final rebirth = rebirthManager?.clickMultiplier ?? 1.0;
    return (base * globalMultiplier * rebirth).floor();
  }

  double get cookiesPerSecond {
    final base = _upgrades.values
        .where((u) => u.type == UpgradeType.passiveIncome)
        .fold(0.0, (sum, u) => sum + u.totalValue);
    final rebirth = rebirthManager?.passiveMultiplier ?? 1.0;
    return base * globalMultiplier * rebirth;
  }

  double get globalMultiplier {
    final multiplierUpgrades =
    _upgrades.values.where((u) => u.type == UpgradeType.multiplier);
    if (multiplierUpgrades.isEmpty) return 1.0;
    return multiplierUpgrades.fold(
        1.0, (product, u) => product * (u.level == 0 ? 1.0 : u.totalValue));
  }

  /// Cost of an upgrade after the active Flash Sale discount is applied.
  int discountedCost(Upgrade u) {
    final discount = rebirthManager?.shopDiscount ?? 0.0;
    if (discount <= 0) return u.currentCost;
    return (u.currentCost * (1 - discount)).floor();
  }

  // --- Purchase logic ---

  bool purchase(String id, ValueNotifier<int> cookieNotifier) {
    final upgrade = _upgrades[id];
    if (upgrade == null) return false;
    if (upgrade.isMaxed) return false;
    final cost = discountedCost(upgrade);
    if (cookieNotifier.value < cost) return false;

    cookieNotifier.value -= cost;
    upgrade.level++;
    changeTick.value++;
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
    changeTick.value++;
  }

  void reset() {
    for (final u in _upgrades.values) {
      u.level = 0;
    }
    changeTick.value++;
  }
}
