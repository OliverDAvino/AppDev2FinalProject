import '../models/upgrade.dart';

class UpgradeDefinitions {
  static List<Upgrade> get all => [
    // --- Click power ---
    Upgrade(
      id: 'better_fingers',
      name: 'Grass Touch',
      description: '+1 flower per click',
      icon: 'assets/images/GrassTouch.png',
      type: UpgradeType.clickPower,
      value: 1,
      baseCost: 10,
      cookiesRequiredToUnlock: 0,
    ),
    Upgrade(
      id: 'golden_touch',
      name: 'Water Touch',
      description: '+10 flowers per click',
      icon: 'assets/images/WaterTouch.png',
      type: UpgradeType.clickPower,
      value: 10,
      baseCost: 250,
      cookiesRequiredToUnlock: 100,
    ),
    Upgrade(
      id: 'diamond_hands',
      name: 'Sun Touch',
      description: '+50 flowers per click',
      icon: 'assets/images/SunTouch.png',
      type: UpgradeType.clickPower,
      value: 50,
      baseCost: 3000,
      cookiesRequiredToUnlock: 1000,
    ),

    // --- Passive income ---
    Upgrade(
      id: 'Tulip',
      name: 'Tulip',
      description: '+1 flower/sec',
      icon: 'assets/images/Tulip.png',
      type: UpgradeType.passiveIncome,
      value: 1,
      baseCost: 50,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 0,
    ),
    Upgrade(
      id: 'cookie_farm',
      name: 'Flower Stand',
      description: '+10 flowers/sec',
      icon: 'assets/images/FlowerStand.png',
      type: UpgradeType.passiveIncome,
      value: 10,
      baseCost: 1100,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 500,
    ),
    Upgrade(
      id: 'cookie_factory',
      name: 'Sakura\'s Blessing',
      icon: 'assets/images/SakuraStill.png',
      type: UpgradeType.passiveIncome,      description: '+50 flowers/sec',

      value: 50,
      baseCost: 12000,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 5000,
    ),
    Upgrade(
      id: 'cookie_mine',
      name: 'Fountain of Growth',
      description: '+260 flowers/sec',
      icon: 'assets/images/FountainStill.png',
      type: UpgradeType.passiveIncome,
      value: 300,
      baseCost: 130000,
      costMultiplier: 1.15,
      cookiesRequiredToUnlock: 50000,
    ),

    // --- Multipliers ---
    Upgrade(
      id: 'double_batch',
      name: 'Sun Power',
      description: 'x2 all production',
      icon: 'assets/images/SunStill.png',
      type: UpgradeType.multiplier,
      value: 2.0,
      baseCost: 50000,
      costMultiplier: 5.0,
      maxLevel: 5,
      cookiesRequiredToUnlock: 10000,
    ),
  ];
}
