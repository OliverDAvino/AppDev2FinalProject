import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  // In-memory cache so saves don't re-fetch from Firestore every 30 seconds.
  final Map<String, String> _usernameCache = {};

  DocumentReference _userDoc(String email) => _db.collection('users').doc(email);
  DocumentReference _usernameDoc(String username) =>
      _db.collection('usernames').doc(username.toLowerCase());

  Future<String?> getUsername(String email) async {
    if (_usernameCache.containsKey(email)) return _usernameCache[email];
    try {
      final snap = await _userDoc(email).get();
      if (!snap.exists) return null;
      final username = (snap.data() as Map<String, dynamic>?)?['username'] as String?;
      if (username != null) _usernameCache[email] = username;
      return username;
    } catch (e) {
      debugPrint('getUsername error: $e');
      return null;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final snap = await _usernameDoc(username).get();
    return snap.exists;
  }

  /// Creates the username reservation and user profile atomically.
  Future<void> createUsername(String email, String username) async {
    final batch = _db.batch();
    batch.set(_usernameDoc(username), {'email': email});
    batch.set(_userDoc(email), {'username': username}, SetOptions(merge: true));
    await batch.commit();
    _usernameCache[email] = username;
  }

  /// Changes username: removes old reservation, creates new one atomically.
  Future<void> updateUsername(String email, String oldUsername, String newUsername) async {
    final batch = _db.batch();
    batch.delete(_usernameDoc(oldUsername));
    batch.set(_usernameDoc(newUsername), {'email': email});
    batch.set(_userDoc(email), {'username': newUsername}, SetOptions(merge: true));
    await batch.commit();
    _usernameCache[email] = newUsername;
  }
}
