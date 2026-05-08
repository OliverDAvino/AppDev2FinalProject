import 'package:flutter/foundation.dart';
import '../models/rebirth_upgrade.dart';
import 'rebirth_definitions.dart';
import 'upgrade_manager.dart';

class RebirthManager {
  static const int flowersPerEnergy = 1000000;

  final Map<String, RebirthUpgrade> _upgrades = {
    for (var u in RebirthDefinitions.all) u.id: u,
  };

  int rebirthEnergy = 0;

  // Fires whenever rebirth energy or any rebirth upgrade level changes so
  // the AppBar / rebirth screen / shop pricing rebuild.
  final ValueNotifier<int> changeTick = ValueNotifier<int>(0);

  List<RebirthUpgrade> get all => _upgrades.values.toList();

  RebirthUpgrade get(String id) => _upgrades[id]!;

  int _levelOf(String id) => _upgrades[id]?.level ?? 0;

  // --- Effect getters ---

  /// Fractional discount applied to every shop upgrade cost.
  double get shopDiscount {
    final lvl = _levelOf('flash_sale');
    if (lvl <= 0) return 0.0;
    if (lvl == 1) return 0.15;
    return 0.25;
  }

  /// Multiplier applied on top of the base click power.
  double get clickMultiplier {
    final lvl = _levelOf('dark_sun_touch');
    final base = lvl == 0 ? 1.0 : (lvl * 4).toDouble(); // 4 / 8 / 12
    return base * _flowerGodMultiplier;
  }

  /// Multiplier applied on top of base passive income.
  double get passiveMultiplier {
    final lvl = _levelOf('time_warp');
    double base;
    switch (lvl) {
      case 0:
        base = 1.0;
        break;
      case 1:
        base = 5.0;
        break;
      case 2:
        base = 10.0;
        break;
      default:
        base = 20.0;
    }
    return base * _flowerGodMultiplier;
  }

  double get _flowerGodMultiplier =>
      _levelOf('flower_god') > 0 ? 1000.0 : 1.0;

  // --- Rebirth action ---

  bool canRebirth(int flowers) => flowers >= flowersPerEnergy;

  int rebirthGain(int flowers) => flowers ~/ flowersPerEnergy;

  /// Performs a rebirth: converts current flowers into rebirth energy,
  /// resets run-only state (flowers + regular upgrades), keeps permanent
  /// upgrades. Returns the energy gained, or 0 if not eligible.
  int performRebirth(
    ValueNotifier<int> cookieNotifier,
    UpgradeManager upgradeManager,
  ) {
    final flowers = cookieNotifier.value;
    if (!canRebirth(flowers)) return 0;
    final gain = rebirthGain(flowers);
    rebirthEnergy += gain;
    cookieNotifier.value = 0;
    upgradeManager.reset();
    changeTick.value++;
    return gain;
  }

  // --- Permanent upgrade purchase ---

  bool purchase(String id) {
    final upgrade = _upgrades[id];
    if (upgrade == null) return false;
    if (upgrade.isMaxed) return false;
    if (rebirthEnergy < upgrade.currentCost) return false;
    rebirthEnergy -= upgrade.currentCost;
    upgrade.level++;
    changeTick.value++;
    return true;
  }

  // --- Serialization ---

  Map<String, dynamic> toJson() => {
    'energy': rebirthEnergy,
    'upgrades': {for (var u in _upgrades.values) u.id: u.level},
  };

  void fromJson(Map<String, dynamic> json) {
    rebirthEnergy = (json['energy'] as num?)?.toInt() ?? 0;
    final upgrades = json['upgrades'];
    if (upgrades is Map) {
      for (final entry in upgrades.entries) {
        final u = _upgrades[entry.key];
        if (u != null) u.level = (entry.value as num).toInt();
      }
    }
    changeTick.value++;
  }

  void resetAll() {
    rebirthEnergy = 0;
    for (final u in _upgrades.values) {
      u.level = 0;
    }
    changeTick.value++;
  }
}
