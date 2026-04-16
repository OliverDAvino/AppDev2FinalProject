// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart';
//
// class AuthService {
//   final _auth = FirebaseAuth.instance;
//   final _googleSignIn = GoogleSignIn();
//
//   User? get currentUser => _auth.currentUser;
//
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       final googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;
//
//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       return await _auth.signInWithCredential(credential);
//     } catch (e) {
//       debugPrint('Google sign-in error: $e');
//       return null;
//     }
//   }
//
//   Future<UserCredential> signInAsGuest() async {
//     return await _auth.signInAnonymously();
//   }
//
//   Future<UserCredential?> linkGuestWithGoogle() async {
//     try {
//       final googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;
//
//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       return await _auth.currentUser!.linkWithCredential(credential);
//     } catch (e) {
//       debugPrint('Link error: $e');
//       return null;
//     }
//   }
//
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }