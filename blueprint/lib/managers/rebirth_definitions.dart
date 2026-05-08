import '../models/rebirth_upgrade.dart';

class RebirthDefinitions {
  // Order here is the display order in the rebirth shop.
  static List<RebirthUpgrade> get all => [
    RebirthUpgrade(
      id: 'flash_sale',
      name: 'Flash Sale',
      description: 'Reduce shop prices (-15%, then -25%)',
      icon: 'assets/images/FlashSale.png',
      baseCost: 5,
      costMultiplier: 15.0,
      maxLevel: 2,
    ),
    RebirthUpgrade(
      id: 'dark_sun_touch',
      name: 'Dark Sun Touch',
      description: 'Multiply click gain (4x / 8x / 12x)',
      icon: 'assets/images/DarkSunStill.png',
      baseCost: 100,
      costMultiplier: 15.0,
      maxLevel: 3,
    ),
    RebirthUpgrade(
      id: 'time_warp',
      name: 'Time Warp',
      description: 'Multiply passive gain (5x / 10x / 20x)',
      icon: 'assets/images/TimeWarp.png',
      baseCost: 150,
      costMultiplier: 17.5,
      maxLevel: 3,
    ),
    RebirthUpgrade(
      id: 'flower_god',
      name: 'Flower God',
      description: '×1000 to ALL income. Single purchase.',
      icon: 'assets/images/FlowerGod.png',
      baseCost: 1000000,
      costMultiplier: 1.0,
      maxLevel: 1,
    ),
  ];
}
