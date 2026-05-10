import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import 'achievement_definitions.dart';

class AchievementManager {
  // Internal map keyed by id for O(1) lookup. Order is preserved via AchievementId.values.
  final Map<AchievementId, Achievement> _achievements = {
    for (final a in AchievementDefinitions.all) a.id: a,
  };

  // Increments on every unlock. AchievementsScreen listens to this to rebuild.
  final ValueNotifier<int> changeTick = ValueNotifier<int>(0);

  // Overlay drains this queue one item at a time via dequeueToast().
  final _toastQueue = <Achievement>[];

  // Increments when a new toast is enqueued. Overlay listens to trigger display.
  final ValueNotifier<int> toastTick = ValueNotifier<int>(0);

  // Returns all achievements in definition order.
  List<Achievement> get all =>
      AchievementId.values.map((id) => _achievements[id]!).toList();

  // Pops the oldest queued toast. Returns null if the queue is empty.
  Achievement? dequeueToast() {
    if (_toastQueue.isEmpty) return null;
    return _toastQueue.removeAt(0);
  }

  // Marks an achievement unlocked. Idempotent — safe to call repeatedly.
  void unlock(AchievementId id) {
    final a = _achievements[id];
    if (a == null || a.isUnlocked) return;
    a.isUnlocked = true;
    _toastQueue.add(a);
    toastTick.value++;
    changeTick.value++;
    // Check meta-achievement after every non-meta unlock.
    if (id != AchievementId.youDidIt) _checkYouDidIt();
  }

  // --- Check entry points (called from purchase / rebirth sites) ---

  // Regular shop upgrades (Tulip, Flower Stand, Sakura, Fountain, click-power, Sun Power).
  void checkUpgrade(String upgradeId, int level) {
    switch (upgradeId) {
      case 'Tulip':
        if (level >= 1)  unlock(AchievementId.firstPlant);
        if (level >= 50) unlock(AchievementId.tulipGarden);
        break;
      case 'cookie_farm': // Flower Stand
        if (level >= 1)  unlock(AchievementId.flowerStand);
        if (level >= 50) unlock(AchievementId.flowerFactory);
        break;
      case 'cookie_factory': // Sakura's Blessing
        if (level >= 1)  unlock(AchievementId.sakuraTree);
        if (level >= 50) unlock(AchievementId.trueSakuraBlessing);
        break;
      case 'cookie_mine': // Fountain of Growth
        if (level >= 1)  unlock(AchievementId.hydration);
        if (level >= 50) unlock(AchievementId.superHydration);
        break;
      case 'better_fingers': // Grass Touch
        if (level >= 1)  unlock(AchievementId.saladFingers);
        if (level >= 50) unlock(AchievementId.handsOfGrass);
        break;
      case 'golden_touch': // Water Touch
        if (level >= 1)  unlock(AchievementId.washYourHands);
        if (level >= 50) unlock(AchievementId.cleanestHandsInTheWest);
        break;
      case 'diamond_hands': // Sun Touch
        if (level >= 1)  unlock(AchievementId.solarFingers);
        if (level >= 50) unlock(AchievementId.ovenMitts);
        break;
      case 'double_batch': // Sun Power
        if (level >= 1)  unlock(AchievementId.solarPower);
        break;
    }
  }

  // Rebirth shop upgrades (Dark Sun Touch, Flash Sale, Time Warp, Flower God).
  void checkRebirthUpgrade(String upgradeId, int level) {
    switch (upgradeId) {
      case 'dark_sun_touch':
        if (level >= 1) unlock(AchievementId.darkSun);
        if (level >= 3) unlock(AchievementId.trueDarkPower);
        break;
      case 'flash_sale':
        if (level >= 1) unlock(AchievementId.goodDeal);
        if (level >= 2) unlock(AchievementId.maximumProfit);
        break;
      case 'time_warp':
        if (level >= 1) unlock(AchievementId.kingCrimson);
        if (level >= 3) unlock(AchievementId.zaWarudo);
        break;
      case 'flower_god':
        if (level >= 1) unlock(AchievementId.heavenlyFlower);
        break;
    }
  }

  // Rebirth action — pass lifetimeRebirthEnergy after the rebirth completes.
  void checkRebirth(int lifetimeEnergy) {
    if (lifetimeEnergy >= 1)       unlock(AchievementId.rebirth);
    if (lifetimeEnergy >= 10000)   unlock(AchievementId.superRebirth);
    if (lifetimeEnergy >= 1000000) unlock(AchievementId.rebirthGod);
  }

  // Unlocks "You Did It!" when every other achievement is already unlocked.
  void _checkYouDidIt() {
    final allOthers = AchievementId.values.where((id) => id != AchievementId.youDidIt);
    if (allOthers.every((id) => _achievements[id]!.isUnlocked)) {
      unlock(AchievementId.youDidIt);
    }
  }

  // --- Serialization ---

  // Produces {"firstPlant": true, "tulipGarden": false, ...} for Firestore.
  Map<String, dynamic> toJson() => {
    for (final a in _achievements.values) a.id.name: a.isUnlocked,
  };

  // Restores state from Firestore. Sets isUnlocked directly — no toasts fired on load.
  void fromJson(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      final id = AchievementId.values.asNameMap()[entry.key];
      if (id != null) _achievements[id]!.isUnlocked = entry.value as bool? ?? false;
    }
    changeTick.value++;
  }

  void reset() {
    for (final a in _achievements.values) {
      a.isUnlocked = false;
    }
    changeTick.value++;
  }
}
