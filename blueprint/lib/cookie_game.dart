import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'components/cookie_component.dart';
import 'components/passive_income_system.dart';
import 'managers/upgrade_manager.dart';

class CookieGame extends FlameGame {
  final upgradeManager = UpgradeManager();
  final cookieNotifier = ValueNotifier<int>(0);

  static const _autoSaveInterval = 30.0;
  double _timeSinceLastSave = 0;

  @override
  Future<void> onLoad() async {
    await loadSave();
    add(CookieComponent(position: size / 2));
    add(PassiveIncomeSystem());
    overlays.add('hud');
    overlays.add('shop');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastSave += dt;
    if (_timeSinceLastSave >= _autoSaveInterval) {
      saveToCloud(); // name kept for compatibility with shop_overlay.dart
      _timeSinceLastSave = 0;
    }
  }

  @override
  void onRemove() {
    saveToCloud();
    cookieNotifier.dispose();
    super.onRemove();
  }

  Future<void> loadSave() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('save');
    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      cookieNotifier.value = (json['cookies'] as num?)?.toInt() ?? 0;
      upgradeManager.fromJson(
          Map<String, dynamic>.from(json['upgrades'] ?? {}));
    }
  }

  // Called saveToCloud to avoid changing shop_overlay.dart
  Future<void> saveToCloud() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('save', jsonEncode({
      'cookies': cookieNotifier.value,
      'upgrades': upgradeManager.toJson(),
    }));
  }
}