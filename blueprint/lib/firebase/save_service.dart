import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';

class SaveService {
  final _db = FirebaseFirestore.instance;
  final _userService = UserService();

  DocumentReference _doc(String uid) => _db.collection('saves').doc(uid);
  DocumentReference _leaderboardDoc(String uid) =>
      _db.collection('leaderboard').doc(uid);

  Future<Map<String, dynamic>?> loadSave(String uid) async {
    try {
      final snapshot = await _doc(uid).get();
      if (!snapshot.exists) return null;
      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Load error: $e');
      return null;
    }
  }

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

      final username = await _userService.getUsername(uid);
      if (username != null) {
        await _leaderboardDoc(uid).set({
          'username': username,
          'score': cookies,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  Future<void> deleteSave(String uid) async {
    try {
      await Future.wait([
        _doc(uid).delete(),
        _leaderboardDoc(uid).delete(),
      ]);
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }
}
