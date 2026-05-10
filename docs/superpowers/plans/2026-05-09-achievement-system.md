# Achievement System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a full achievement system to Garden Clicker — model, definitions, manager, persistent save/load, toast notifications, and an achievements screen.

**Architecture:** `AchievementManager` mirrors the existing `UpgradeManager`/`RebirthManager` pattern: injected into `CookieGame`, checked at purchase call sites (shop and rebirth screen), serialized as a new `achievements` key in the Firestore save document. Toast notifications use a queue drained by a Flutter overlay widget sitting on top of the game Stack.

**Tech Stack:** Flutter/Dart, Flame, Firebase Firestore, `ValueNotifier` for reactivity

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `lib/models/achievement.dart` | Create | `Achievement` class + `AchievementId` enum |
| `lib/managers/achievement_definitions.dart` | Create | Static list of all 26 achievement definitions |
| `lib/managers/achievement_manager.dart` | Create | Unlock logic, toast queue, serialization |
| `lib/overlays/achievement_toast_overlay.dart` | Create | Animated toast UI, drains queue one at a time |
| `lib/screens/achievements_screen.dart` | Create | Full-screen achievement list with locked/unlocked states |
| `lib/managers/rebirth_manager.dart` | Modify | Add `lifetimeRebirthEnergy` field |
| `lib/firebase/save_service.dart` | Modify | Add optional `achievements` param to `writeSave` |
| `lib/cookie_game.dart` | Modify | Add `achievementManager`, wire save/load |
| `lib/overlays/shop_overlay.dart` | Modify | Call achievement check after successful purchase |
| `lib/screens/rebirth_screen.dart` | Modify | Call achievement checks after rebirth and upgrade purchase |
| `lib/screens/game_screen.dart` | Modify | Add toast overlay to Stack, add Achievements AppBar button |

---

## Task 1: Achievement Model + Enum

**Files:**
- Create: `lib/models/achievement.dart`

- [ ] **Create `lib/models/achievement.dart`**

```dart
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
```

- [ ] **Verify** — run `flutter analyze lib/models/achievement.dart` and confirm no errors.

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/models/achievement.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && git add lib/models/achievement.dart && git commit -m "feat: add Achievement model and AchievementId enum"
```

---

## Task 2: Achievement Definitions

**Files:**
- Create: `lib/managers/achievement_definitions.dart`

- [ ] **Create `lib/managers/achievement_definitions.dart`**

```dart
import '../models/achievement.dart';

// All 26 achievements in display order. Edit here to add future achievements.
class AchievementDefinitions {
  static List<Achievement> get all => [
    // --- Tulip ---
    Achievement(id: AchievementId.firstPlant,          title: 'First Plant',                description: 'Purchase 1 Tulip',                         icon: 'assets/images/Tulip.png'),
    Achievement(id: AchievementId.tulipGarden,         title: 'Tulip Garden',               description: 'Purchase 50 Tulips',                        icon: 'assets/images/Tulip.png'),
    // --- Flower Stand ---
    Achievement(id: AchievementId.flowerStand,         title: 'Flower Stand',               description: 'Purchase 1 Flower Stand',                   icon: 'assets/images/FlowerStand.png'),
    Achievement(id: AchievementId.flowerFactory,       title: 'Flower Factory',             description: 'Purchase 50 Flower Stands',                 icon: 'assets/images/FlowerStand.png'),
    // --- Sakura ---
    Achievement(id: AchievementId.sakuraTree,          title: "Sakura Tree",                description: "Purchase 1 Sakura's Blessing",              icon: 'assets/images/SakuraStill.png'),
    Achievement(id: AchievementId.trueSakuraBlessing,  title: "True Sakura Blessing",       description: "Purchase 50 Sakura's Blessings",            icon: 'assets/images/SakuraStill.png'),
    // --- Fountain ---
    Achievement(id: AchievementId.hydration,           title: 'Hydration',                  description: 'Purchase 1 Fountain of Growth',             icon: 'assets/images/FountainStill.png'),
    Achievement(id: AchievementId.superHydration,      title: 'Super Hydration',            description: 'Purchase 50 Fountains of Growth',           icon: 'assets/images/FountainStill.png'),
    // --- Grass Touch ---
    Achievement(id: AchievementId.saladFingers,        title: 'Salad Fingers',              description: 'Purchase 1 Grass Touch',                    icon: 'assets/images/GrassTouch.png'),
    Achievement(id: AchievementId.handsOfGrass,        title: 'Hands of Grass',             description: 'Purchase 50 Grass Touch',                   icon: 'assets/images/GrassTouch.png'),
    // --- Water Touch ---
    Achievement(id: AchievementId.washYourHands,       title: 'Wash Your Hands',            description: 'Purchase 1 Water Touch',                    icon: 'assets/images/WaterTouch.png'),
    Achievement(id: AchievementId.cleanestHandsInTheWest, title: 'Cleanest Hands in the West', description: 'Purchase 50 Water Touch',               icon: 'assets/images/WaterTouch.png'),
    // --- Sun Touch ---
    Achievement(id: AchievementId.solarFingers,        title: 'Solar Fingers',              description: 'Purchase 1 Sun Touch',                      icon: 'assets/images/SunTouch.png'),
    Achievement(id: AchievementId.ovenMitts,           title: 'Oven Mitts',                 description: 'Purchase 50 Sun Touch',                     icon: 'assets/images/SunTouch.png'),
    // --- Sun Power ---
    Achievement(id: AchievementId.solarPower,          title: 'Solar Power',                description: 'Purchase 1 Sun Power',                      icon: 'assets/images/SunStill.png'),
    // --- Rebirth ---
    Achievement(id: AchievementId.rebirth,             title: 'Rebirth!',                   description: 'Rebirth for the first time',                icon: 'assets/images/RebirthEnergy.png'),
    Achievement(id: AchievementId.superRebirth,        title: 'Super Rebirth',              description: 'Earn 10,000 lifetime rebirth energy',       icon: 'assets/images/RebirthEnergy.png'),
    Achievement(id: AchievementId.rebirthGod,          title: 'Rebirth God',                description: 'Earn 1,000,000 lifetime rebirth energy',    icon: 'assets/images/RebirthEnergy.png'),
    // --- Dark Sun ---
    Achievement(id: AchievementId.darkSun,             title: 'Dark Sun',                   description: 'Purchase Dark Sun Touch',                   icon: 'assets/images/DarkSunStill.png'),
    Achievement(id: AchievementId.trueDarkPower,       title: 'True Dark Power',            description: 'Max out Dark Sun Touch (level 3)',          icon: 'assets/images/DarkSunStill.png'),
    // --- Flash Sale ---
    Achievement(id: AchievementId.goodDeal,            title: 'Good Deal!',                 description: 'Purchase Flash Sale',                       icon: 'assets/images/FlashSale.png'),
    Achievement(id: AchievementId.maximumProfit,       title: 'Maximum Profit',             description: 'Max out Flash Sale (level 2)',              icon: 'assets/images/FlashSale.png'),
    // --- Time Warp ---
    Achievement(id: AchievementId.kingCrimson,         title: 'King Crimson!',              description: 'Purchase Time Warp',                        icon: 'assets/images/TimeWarp.png'),
    Achievement(id: AchievementId.zaWarudo,            title: 'Za Warudo!!!',               description: 'Max out Time Warp (level 3)',               icon: 'assets/images/TimeWarp.png'),
    // --- Flower God ---
    Achievement(id: AchievementId.heavenlyFlower,      title: 'Heavenly Flower',            description: 'Purchase Flower God',                       icon: 'assets/images/FlowerGod.png'),
    // --- Meta ---
    Achievement(id: AchievementId.youDidIt,            title: 'You Did It!',                description: 'Unlock every other achievement',            icon: 'assets/images/MainFlower.png'),
  ];
}
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/managers/achievement_definitions.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/managers/achievement_definitions.dart && git commit -m "feat: add achievement definitions (26 achievements)"
```

---

## Task 3: Achievement Manager

**Files:**
- Create: `lib/managers/achievement_manager.dart`

- [ ] **Create `lib/managers/achievement_manager.dart`**

```dart
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

  // Restores state from a Firestore map. Sets isUnlocked directly (no toasts on load).
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
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/managers/achievement_manager.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/managers/achievement_manager.dart && git commit -m "feat: add AchievementManager with unlock logic, toast queue, and serialization"
```

---

## Task 4: Add `lifetimeRebirthEnergy` to RebirthManager

**Files:**
- Modify: `lib/managers/rebirth_manager.dart`

- [ ] **Add `lifetimeRebirthEnergy` field declaration** after `int rebirthEnergy = 0;` (line 13)

Old:
```dart
  int rebirthEnergy = 0;
```

New:
```dart
  int rebirthEnergy = 0;

  // Total rebirth energy ever earned — never decrements when energy is spent.
  int lifetimeRebirthEnergy = 0;
```

- [ ] **Increment `lifetimeRebirthEnergy` inside `performRebirth`** — add one line after `rebirthEnergy += gain;`

Old:
```dart
    final gain = rebirthGain(flowers);
    rebirthEnergy += gain;
    cookieNotifier.value = 0;
```

New:
```dart
    final gain = rebirthGain(flowers);
    rebirthEnergy += gain;
    lifetimeRebirthEnergy += gain;
    cookieNotifier.value = 0;
```

- [ ] **Persist in `toJson`**

Old:
```dart
  Map<String, dynamic> toJson() => {
    'energy': rebirthEnergy,
    'upgrades': {for (var u in _upgrades.values) u.id: u.level},
  };
```

New:
```dart
  Map<String, dynamic> toJson() => {
    'energy': rebirthEnergy,
    'lifetimeEnergy': lifetimeRebirthEnergy,
    'upgrades': {for (var u in _upgrades.values) u.id: u.level},
  };
```

- [ ] **Restore in `fromJson`** — add one line after the `rebirthEnergy` line

Old:
```dart
    rebirthEnergy = (json['energy'] as num?)?.toInt() ?? 0;
```

New:
```dart
    rebirthEnergy = (json['energy'] as num?)?.toInt() ?? 0;
    lifetimeRebirthEnergy = (json['lifetimeEnergy'] as num?)?.toInt() ?? 0;
```

- [ ] **Reset in `resetAll`**

Old:
```dart
  void resetAll() {
    rebirthEnergy = 0;
    for (final u in _upgrades.values) {
```

New:
```dart
  void resetAll() {
    rebirthEnergy = 0;
    lifetimeRebirthEnergy = 0;
    for (final u in _upgrades.values) {
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/managers/rebirth_manager.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/managers/rebirth_manager.dart && git commit -m "feat: track lifetimeRebirthEnergy in RebirthManager"
```

---

## Task 5: Update SaveService

**Files:**
- Modify: `lib/firebase/save_service.dart`

- [ ] **Add optional `achievements` parameter to `writeSave`**

Old:
```dart
  Future<void> writeSave(
    String uid, {
    required int cookies,
    required Map<String, dynamic> upgrades,
    Map<String, dynamic>? rebirth,
  }) async {
    try {
      await _doc(uid).set({
        'cookies': cookies,
        'upgrades': upgrades,
        if (rebirth != null) 'rebirth': rebirth,
        'lastSaved': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
```

New:
```dart
  Future<void> writeSave(
    String uid, {
    required int cookies,
    required Map<String, dynamic> upgrades,
    Map<String, dynamic>? rebirth,
    Map<String, dynamic>? achievements,
  }) async {
    try {
      await _doc(uid).set({
        'cookies': cookies,
        'upgrades': upgrades,
        if (rebirth != null) 'rebirth': rebirth,
        if (achievements != null) 'achievements': achievements,
        'lastSaved': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/firebase/save_service.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/firebase/save_service.dart && git commit -m "feat: add achievements param to SaveService.writeSave"
```

---

## Task 6: Wire AchievementManager into CookieGame

**Files:**
- Modify: `lib/cookie_game.dart`

- [ ] **Add import and field**

Add import at the top:
```dart
import 'managers/achievement_manager.dart';
```

Add field after `final _saveService = SaveService();`:
```dart
  final achievementManager = AchievementManager();
```

- [ ] **Pass achievements to `saveToCloud`**

Old:
```dart
    await _saveService.writeSave(
      email,
      cookies: cookieNotifier.value,
      upgrades: upgradeManager.toJson(),
      rebirth: rebirthManager.toJson(),
    );
```

New:
```dart
    await _saveService.writeSave(
      email,
      cookies: cookieNotifier.value,
      upgrades: upgradeManager.toJson(),
      rebirth: rebirthManager.toJson(),
      achievements: achievementManager.toJson(),
    );
```

- [ ] **Load achievements in `loadSave`**

Add after the `rebirth` loading block:
```dart
      final achievementsData = data['achievements'];
      if (achievementsData is Map) {
        achievementManager.fromJson(Map<String, dynamic>.from(achievementsData));
      }
```

- [ ] **Reset achievements in `resetAndSuppressSave`**

Add after `rebirthManager.resetAll();`:
```dart
    achievementManager.reset();
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/cookie_game.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/cookie_game.dart && git commit -m "feat: add achievementManager to CookieGame, wire save/load/reset"
```

---

## Task 7: Hook Achievement Checks into ShopOverlay

**Files:**
- Modify: `lib/overlays/shop_overlay.dart`

- [ ] **Add achievement check after a successful shop purchase**

In `_ShopOverlayState.build`, find the `onBuy` callback (around line 64). Replace it:

Old:
```dart
                        onBuy: () {
                          final bought = manager.purchase(
                            visible[i].id,
                            widget.game.cookieNotifier,
                          );
                          if (bought) {
                            widget.game.saveToCloud();
                            setState(() {});
                          }
                        },
```

New:
```dart
                        onBuy: () {
                          final id = visible[i].id;
                          final bought = manager.purchase(
                            id,
                            widget.game.cookieNotifier,
                          );
                          if (bought) {
                            widget.game.achievementManager.checkUpgrade(
                              id,
                              manager.levelOf(id),
                            );
                            widget.game.saveToCloud();
                            setState(() {});
                          }
                        },
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/overlays/shop_overlay.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/overlays/shop_overlay.dart && git commit -m "feat: check achievements after shop upgrade purchase"
```

---

## Task 8: Hook Achievement Checks into RebirthScreen

**Files:**
- Modify: `lib/screens/rebirth_screen.dart`

- [ ] **Add achievement check after rebirth upgrade purchase** — in the `onBuy` callback for `_PermanentUpgradeTile` (around line 128)

Old:
```dart
                          onBuy: () {
                            final ok = rm.purchase(u.id);
                            if (ok) {
                              widget.game.saveToCloud();
                              setState(() {});
                            }
                          },
```

New:
```dart
                          onBuy: () {
                            final ok = rm.purchase(u.id);
                            if (ok) {
                              widget.game.achievementManager.checkRebirthUpgrade(
                                u.id,
                                rm.get(u.id).level,
                              );
                              widget.game.saveToCloud();
                              setState(() {});
                            }
                          },
```

- [ ] **Add achievement check after rebirth action** — in `_doRebirth` (around line 39), after `performRebirth` is called

Old:
```dart
              widget.game.rebirthManager.performRebirth(
                widget.game.cookieNotifier,
                widget.game.upgradeManager,
              );
              widget.game.saveToCloud();
              Navigator.of(context).pop();
```

New:
```dart
              widget.game.rebirthManager.performRebirth(
                widget.game.cookieNotifier,
                widget.game.upgradeManager,
              );
              widget.game.achievementManager.checkRebirth(
                widget.game.rebirthManager.lifetimeRebirthEnergy,
              );
              widget.game.saveToCloud();
              Navigator.of(context).pop();
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/screens/rebirth_screen.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/screens/rebirth_screen.dart && git commit -m "feat: check achievements after rebirth upgrade purchase and rebirth action"
```

---

## Task 9: Achievement Toast Overlay

**Files:**
- Create: `lib/overlays/achievement_toast_overlay.dart`

- [ ] **Create `lib/overlays/achievement_toast_overlay.dart`**

```dart
import 'package:flutter/material.dart';
import '../managers/achievement_manager.dart';
import '../models/achievement.dart';

// Displays achievement unlock toasts one at a time.
// Must be placed inside a Stack that covers the full screen.
class AchievementToastOverlay extends StatefulWidget {
  final AchievementManager manager;
  const AchievementToastOverlay({required this.manager, super.key});

  @override
  State<AchievementToastOverlay> createState() => _AchievementToastOverlayState();
}

class _AchievementToastOverlayState extends State<AchievementToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Achievement? _current;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    widget.manager.toastTick.addListener(_onNewToast);
  }

  @override
  void dispose() {
    widget.manager.toastTick.removeListener(_onNewToast);
    _controller.dispose();
    super.dispose();
  }

  void _onNewToast() {
    if (!_isShowing) _showNext();
  }

  Future<void> _showNext() async {
    final next = widget.manager.dequeueToast();
    if (next == null) return;
    if (!mounted) return;

    setState(() {
      _current = next;
      _isShowing = true;
    });

    await _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    await _controller.reverse();
    if (!mounted) return;

    setState(() {
      _current = null;
      _isShowing = false;
    });

    // Recursively drain remaining queue items.
    _showNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: _ToastCard(achievement: _current!),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final Achievement achievement;
  const _ToastCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade900.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.lightGreenAccent, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(achievement.icon, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/overlays/achievement_toast_overlay.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/overlays/achievement_toast_overlay.dart && git commit -m "feat: add AchievementToastOverlay with slide+fade animation and queue draining"
```

---

## Task 10: Achievements Screen

**Files:**
- Create: `lib/screens/achievements_screen.dart`

- [ ] **Create `lib/screens/achievements_screen.dart`**

```dart
import 'package:flutter/material.dart';
import '../managers/achievement_manager.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  final AchievementManager manager;
  const AchievementsScreen({required this.manager, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text('Achievements',
            style: TextStyle(color: Colors.lightGreenAccent)),
        iconTheme: const IconThemeData(color: Colors.lightGreenAccent),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: manager.changeTick,
        builder: (_, __, ___) {
          final achievements = manager.all;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '$unlockedCount / ${achievements.length} Unlocked',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: achievements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) =>
                      _AchievementTile(achievement: achievements[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade800,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: unlocked ? Colors.lightGreenAccent : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(achievement.icon, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      color: unlocked ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: unlocked ? Colors.white70 : Colors.white38,
                      fontSize: 12,
                      fontStyle:
                          unlocked ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.check_circle,
                  color: Colors.lightGreenAccent, size: 20),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/screens/achievements_screen.dart
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/screens/achievements_screen.dart && git commit -m "feat: add AchievementsScreen with locked/unlocked tile states"
```

---

## Task 11: Wire Toast + Achievements Button into GameScreen

**Files:**
- Modify: `lib/screens/game_screen.dart`

- [ ] **Add imports** at the top of `game_screen.dart`

```dart
import '../overlays/achievement_toast_overlay.dart';
import '../screens/achievements_screen.dart';
```

- [ ] **Add Achievements button to AppBar actions** — insert before the Upgrades button (`Icons.upgrade`)

```dart
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.amberAccent),
            tooltip: 'Achievements',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AchievementsScreen(
                  manager: _game.achievementManager,
                ),
              ),
            ),
          ),
```

- [ ] **Add toast overlay as the topmost child of the body Stack**

Old:
```dart
          // Flame game (transparent background) sits on top of the garden visuals.
          GameWidget(
```

New:
```dart
          // Flame game (transparent background) sits on top of the garden visuals.
          GameWidget(
```

Add after the closing `)` of `GameWidget(...)`:
```dart
          // Achievement toasts float above everything else.
          AchievementToastOverlay(manager: _game.achievementManager),
```

So the full Stack children list becomes:
```dart
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([
                _game.upgradeManager.changeTick,
                _game.rebirthManager.changeTick,
              ]),
              builder: (_, __) => GardenVisuals(manager: _game.upgradeManager),
            ),
            GameWidget(
              game: _game,
              overlayBuilderMap: {
                'hud': (_, game) => HudOverlay(game: game as CookieGame),
                'shop': (_, game) => ShopOverlay(game: game as CookieGame),
              },
              initialActiveOverlays: const ['hud'],
            ),
            AchievementToastOverlay(manager: _game.achievementManager),
          ],
```

- [ ] **Verify**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze lib/screens/game_screen.dart
```

Expected: `No issues found!`

- [ ] **Full project analyze**

```bash
cd /Users/oliverdavino/StudioProjects/AppDev2FinalProject/blueprint && flutter analyze
```

Expected: `No issues found!`

- [ ] **Commit**

```bash
git add lib/screens/game_screen.dart && git commit -m "feat: add AchievementsScreen button and toast overlay to GameScreen"
```

---

## Self-Review Checklist

- [x] All 26 achievements defined and mapped to check logic
- [x] `lifetimeRebirthEnergy` persisted and restored (null-safe for old saves)
- [x] Toast queue drains sequentially, not concurrently
- [x] `unlock()` is idempotent — safe to call on every purchase, including on load
- [x] `fromJson` sets `isUnlocked` directly (no toasts fired on save load)
- [x] "You Did It!" cannot recurse infinitely — guarded by `id != youDidIt` check
- [x] `achievementManager.reset()` called in `resetAndSuppressSave` so a save wipe also clears achievements
- [x] All icon asset paths confirmed present in `assets/images/`
- [x] Rebirth upgrade check uses `rm.get(u.id).level` which is the *new* level after purchase
