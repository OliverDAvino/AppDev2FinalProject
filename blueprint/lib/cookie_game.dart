import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'components/cookie_component.dart';
import 'components/passive_income_system.dart';
import 'managers/rebirth_manager.dart';
import 'managers/upgrade_manager.dart';
import 'firebase/save_service.dart';

class CookieGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);

  final upgradeManager = UpgradeManager();
  final rebirthManager = RebirthManager();
  final cookieNotifier = ValueNotifier<int>(0);
  final _saveService = SaveService();

  CookieGame() {
    upgradeManager.rebirthManager = rebirthManager;
  }

  static const _autoSaveInterval = 30.0;
  double _timeSinceLastSave = 0;
  StreamSubscription<User?>? _authSubscription;

  // Set after a manual reset so pending auto-saves and onRemove don't
  // resurrect the deleted cloud save.
  bool _suppressSave = false;

  @override
  Future<void> onLoad() async {
    await loadSave();
    add(CookieComponent(position: size / 2));
    add(PassiveIncomeSystem());
    overlays.add('hud');

    _authSubscription = FirebaseAuth.instance.authStateChanges().skip(1).listen((_) {
      _reloadSave();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastSave += dt;
    if (_timeSinceLastSave >= _autoSaveInterval) {
      saveToCloud();
      _timeSinceLastSave = 0;
    }
  }

  @override
  void onRemove() {
    _authSubscription?.cancel();
    saveToCloud();
    cookieNotifier.dispose();
    super.onRemove();
  }

  Future<void> _reloadSave() async {
    cookieNotifier.value = 0;
    upgradeManager.reset();
    rebirthManager.resetAll();
    await loadSave();
  }

  Future<void> loadSave() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return; // guests always start fresh
    final data = await _saveService.loadSave(email);
    if (data != null) {
      cookieNotifier.value = (data['cookies'] as num?)?.toInt() ?? 0;
      upgradeManager.fromJson(
          Map<String, dynamic>.from(data['upgrades'] ?? {}));
      final rebirth = data['rebirth'];
      if (rebirth is Map) {
        rebirthManager.fromJson(Map<String, dynamic>.from(rebirth));
      }
    }
  }

  Future<void> saveToCloud() async {
    if (_suppressSave) return;
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return; // only save for logged-in users
    await _saveService.writeSave(
      email,
      cookies: cookieNotifier.value,
      upgrades: upgradeManager.toJson(),
      rebirth: rebirthManager.toJson(),
    );
  }

  // Wipes in-memory state and prevents future writes from this instance.
  // Use after deleting the cloud save so onRemove / auto-save can't restore it.
  void resetAndSuppressSave() {
    _suppressSave = true;
    cookieNotifier.value = 0;
    upgradeManager.reset();
    rebirthManager.resetAll();
  }
}
