// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flame/game.dart';
// import 'package:flutter/material.dart';
// import '../cookie_game.dart';
// import '../overlays/hud_overlay.dart';
// import '../overlays/shop_overlay.dart';
//
// class GameLoader extends StatefulWidget {
//   final User user;
//   const GameLoader({required this.user, super.key});
//
//   @override
//   State<GameLoader> createState() => _GameLoaderState();
// }
//
// class _GameLoaderState extends State<GameLoader> {
//   CookieGame? _game;
//
//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }
//
//   Future<void> _init() async {
//     final game = CookieGame(user: widget.user);
//     await game.loadFromCloud();
//     if (mounted) setState(() => _game = game);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_game == null) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('🍪', style: TextStyle(fontSize: 50)),
//               SizedBox(height: 16),
//               CircularProgressIndicator(color: Colors.amber),
//               SizedBox(height: 12),
//               Text('Loading your cookies...',
//                   style: TextStyle(color: Colors.white54)),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return GameWidget(
//       game: _game!,
//       overlayBuilderMap: {
//         'hud': (_, game) => HudOverlay(game: game as CookieGame),
//         'shop': (_, game) => ShopOverlay(game: game as CookieGame),
//       },
//       initialActiveOverlays: const ['hud', 'shop'],
//     );
//   }
// }