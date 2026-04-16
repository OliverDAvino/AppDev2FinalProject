// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'screens/main_menu_screen.dart';
// import 'screens/game_loader.dart';
//
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             backgroundColor: Colors.black,
//             body: Center(
//               child: CircularProgressIndicator(color: Colors.amber),
//             ),
//           );
//         }
//         if (snapshot.hasData && snapshot.data != null) {
//           return GameLoader(user: snapshot.data!);
//         }
//         return const MainMenuScreen();
//       },
//     );
//   }
// }