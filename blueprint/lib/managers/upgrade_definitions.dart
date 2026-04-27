import '../models/upgrade.dart';

class UpgradeDefinitions {
  static List<Upgrade> get all => [
    // --- Click power ---
    Upgrade(
      id: 'better_fingers',
      name: 'Green Thumb',
      description: '+1 flower per click',
      icon: '🌱',
      type: UpgradeType.clickPower,
      value: 1,
      baseCost: 10,
      cookiesRequiredToUnlock: 0,
    ),
    Upgrade(
      id: 'golden_touch',
      name: 'Petal Touch',
      description: '+10 flowers per click',
      icon: '🌸',
      type: UpgradeType.clickPower,
      value: 10,
      baseCost: 500,
      cookiesRequiredToUnlock: 100,
    ),
    Upgrade(
      id: 'diamond_hands',
      name: 'Bloom Hands',
      description: '+50 flowers per click',
      icon: '💐',
      type: UpgradeType.clickPower,
      value: 50,
      baseCost: 5000,
      cookiesRequiredToUnlock: 1000,
    ),

    // --- Passive income ---
    Upgrade(
      id: 'grandma',
      name: 'Gardener',
      description: '+1 flower/sec',
      icon: '👩‍🌾',
      type: UpgradeType.passiveIncome,
      value: 1,
      baseCost: 100,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 0,
    ),
    Upgrade(
      id: 'cookie_farm',
      name: 'Flower Bed',
      description: '+8 flowers/sec',
      icon: '🌻',
      type: UpgradeType.passiveIncome,
      value: 8,
      baseCost: 1100,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 500,
    ),
    Upgrade(
      id: 'cookie_factory',
      name: 'Greenhouse',
      description: '+47 flowers/sec',
      icon: '🏡',
      type: UpgradeType.passiveIncome,
      value: 47,
      baseCost: 12000,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 5000,
    ),
    Upgrade(
      id: 'cookie_mine',
      name: 'Botanical Garden',
      description: '+260 flowers/sec',
      icon: '🌿',
      type: UpgradeType.passiveIncome,
      value: 260,
      baseCost: 130000,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 50000,
    ),

    // --- Multipliers ---
    Upgrade(
      id: 'double_batch',
      name: 'Full Bloom',
      description: 'x2 all production',
      icon: '🌺',
      type: UpgradeType.multiplier,
      value: 2.0,
      baseCost: 50000,
      costMultiplier: 5.0,
      maxLevel: 5,
      cookiesRequiredToUnlock: 10000,
    ),
  ];
}
