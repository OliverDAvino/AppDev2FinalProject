import '../models/achievement.dart';

// All 26 achievements in display order. Add new achievements here to extend the system.
class AchievementDefinitions {
  static List<Achievement> get all => [
    // --- Tulip ---
    Achievement(id: AchievementId.firstPlant,             title: 'First Plant',                    description: 'Purchase 1 Tulip',                        icon: 'assets/images/Tulip.png'),
    Achievement(id: AchievementId.tulipGarden,            title: 'Tulip Garden',                   description: 'Purchase 50 Tulips',                       icon: 'assets/images/Tulip.png'),
    // --- Flower Stand ---
    Achievement(id: AchievementId.flowerStand,            title: 'Flower Stand',                   description: 'Purchase 1 Flower Stand',                  icon: 'assets/images/FlowerStand.png'),
    Achievement(id: AchievementId.flowerFactory,          title: 'Flower Factory',                 description: 'Purchase 50 Flower Stands',                icon: 'assets/images/FlowerStand.png'),
    // --- Sakura ---
    Achievement(id: AchievementId.sakuraTree,             title: "Sakura Tree",                    description: "Purchase 1 Sakura's Blessing",             icon: 'assets/images/SakuraStill.png'),
    Achievement(id: AchievementId.trueSakuraBlessing,     title: "True Sakura Blessing",           description: "Purchase 50 Sakura's Blessings",           icon: 'assets/images/SakuraStill.png'),
    // --- Fountain ---
    Achievement(id: AchievementId.hydration,              title: 'Hydration',                      description: 'Purchase 1 Fountain of Growth',            icon: 'assets/images/FountainStill.png'),
    Achievement(id: AchievementId.superHydration,         title: 'Super Hydration',                description: 'Purchase 50 Fountains of Growth',          icon: 'assets/images/FountainStill.png'),
    // --- Grass Touch ---
    Achievement(id: AchievementId.saladFingers,           title: 'Salad Fingers',                  description: 'Purchase 1 Grass Touch',                   icon: 'assets/images/GrassTouch.png'),
    Achievement(id: AchievementId.handsOfGrass,           title: 'Hands of Grass',                 description: 'Purchase 50 Grass Touch',                  icon: 'assets/images/GrassTouch.png'),
    // --- Water Touch ---
    Achievement(id: AchievementId.washYourHands,          title: 'Wash Your Hands',                description: 'Purchase 1 Water Touch',                   icon: 'assets/images/WaterTouch.png'),
    Achievement(id: AchievementId.cleanestHandsInTheWest, title: 'Cleanest Hands in the West',     description: 'Purchase 50 Water Touch',                  icon: 'assets/images/WaterTouch.png'),
    // --- Sun Touch ---
    Achievement(id: AchievementId.solarFingers,           title: 'Solar Fingers',                  description: 'Purchase 1 Sun Touch',                     icon: 'assets/images/SunTouch.png'),
    Achievement(id: AchievementId.ovenMitts,              title: 'Oven Mitts',                     description: 'Purchase 50 Sun Touch',                    icon: 'assets/images/SunTouch.png'),
    // --- Sun Power ---
    Achievement(id: AchievementId.solarPower,             title: 'Solar Power',                    description: 'Purchase 1 Sun Power',                     icon: 'assets/images/SunStill.png'),
    // --- Rebirth ---
    Achievement(id: AchievementId.rebirth,                title: 'Rebirth!',                       description: 'Rebirth for the first time',               icon: 'assets/images/RebirthEnergy.png'),
    Achievement(id: AchievementId.superRebirth,           title: 'Super Rebirth',                  description: 'Earn 10,000 lifetime rebirth energy',      icon: 'assets/images/RebirthEnergy.png'),
    Achievement(id: AchievementId.rebirthGod,             title: 'Rebirth God',                    description: 'Earn 1,000,000 lifetime rebirth energy',   icon: 'assets/images/RebirthEnergy.png'),
    // --- Dark Sun ---
    Achievement(id: AchievementId.darkSun,                title: 'Dark Sun',                       description: 'Purchase Dark Sun Touch',                  icon: 'assets/images/DarkSunStill.png'),
    Achievement(id: AchievementId.trueDarkPower,          title: 'True Dark Power',                description: 'Max out Dark Sun Touch (level 3)',         icon: 'assets/images/DarkSunStill.png'),
    // --- Flash Sale ---
    Achievement(id: AchievementId.goodDeal,               title: 'Good Deal!',                     description: 'Purchase Flash Sale',                      icon: 'assets/images/FlashSale.png'),
    Achievement(id: AchievementId.maximumProfit,          title: 'Maximum Profit',                 description: 'Max out Flash Sale (level 2)',             icon: 'assets/images/FlashSale.png'),
    // --- Time Warp ---
    Achievement(id: AchievementId.kingCrimson,            title: 'King Crimson!',                  description: 'Purchase Time Warp',                       icon: 'assets/images/TimeWarp.png'),
    Achievement(id: AchievementId.zaWarudo,               title: 'Za Warudo!!!',                   description: 'Max out Time Warp (level 3)',              icon: 'assets/images/TimeWarp.png'),
    // --- Flower God ---
    Achievement(id: AchievementId.heavenlyFlower,         title: 'Heavenly Flower',                description: 'Purchase Flower God',                      icon: 'assets/images/FlowerGod.png'),
    // --- Meta ---
    Achievement(id: AchievementId.youDidIt,               title: 'You Did It!',                    description: 'Unlock every other achievement',           icon: 'assets/images/MainFlower.png'),
  ];
}
