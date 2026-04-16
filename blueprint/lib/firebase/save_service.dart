// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
//
// class SaveService {
//   final _db = FirebaseFirestore.instance;
//
//   DocumentReference _doc(String uid) => _db.collection('saves').doc(uid);
//
//   Future<Map<String, dynamic>?> loadSave(String uid) async {
//     try {
//       final snapshot = await _doc(uid).get();
//       if (!snapshot.exists) return null;
//       return snapshot.data() as Map<String, dynamic>;
//     } catch (e) {
//       debugPrint('Load error: $e');
//       return null;
//     }
//   }
//
//   Future<void> writeSave(
//       String uid, {
//         required int cookies,
//         required Map<String, dynamic> upgrades,
//       }) async {
//     try {
//       await _doc(uid).set({
//         'cookies': cookies,
//         'upgrades': upgrades,
//         'lastSaved': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     } catch (e) {
//       debugPrint('Save error: $e');
//     }
//   }
//
//   Future<void> deleteSave(String uid) async {
//     try {
//       await _doc(uid).delete();
//     } catch (e) {
//       debugPrint('Delete error: $e');
//     }
//   }
// }