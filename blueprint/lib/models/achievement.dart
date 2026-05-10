// Unique identifier for every achievement. Using an enum avoids raw string IDs.
enum AchievementId {
  firstPlant, tulipGarden,
  flowerStand, flowerFactory,
  sakuraTree, trueSakuraBlessing,
  hydration, superHydration,
  saladFingers, handsOfGrass,
  washYourHands, cleanestHandsInTheWest,
  solarFingers, ovenMitts,
  solarPower,
  rebirth, superRebirth, rebirthGod,
  darkSun, trueDarkPower,
  goodDeal, maximumProfit,
  kingCrimson, zaWarudo,
  heavenlyFlower,
  youDidIt,
}

class Achievement {
  final AchievementId id;
  final String title;
  // Shown as the unlock requirement on locked tiles; shown as flavour text when unlocked.
  final String description;
  final String icon; // always an assets/ path
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}
