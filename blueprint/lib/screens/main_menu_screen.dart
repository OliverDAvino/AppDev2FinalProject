import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../auth.dart';
import '../pages/login_register_page.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: SafeArea(
        child: Center(
          child: StreamBuilder<User?>(
            stream: Auth().authStateChanges,
            builder: (context, snapshot) {
              final isLoggedIn = snapshot.data != null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Garden Clicker',
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text('🌸', style: TextStyle(fontSize: 64)),
                  if (isLoggedIn)
                    Text(
                      snapshot.data!.email ?? '',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  const SizedBox(height: 48),
                  _MenuButton(
                    label: 'Play',
                    icon: Icons.play_arrow,
                    color: Colors.lightGreenAccent,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    label: 'Leaderboard',
                    icon: Icons.leaderboard,
                    color: Colors.amberAccent,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                    ),
                  ),
                  if (isLoggedIn) ...[
                    const SizedBox(height: 16),
                    _MenuButton(
                      label: 'Profile',
                      icon: Icons.person,
                      color: Colors.lightBlueAccent,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (isLoggedIn)
                    _MenuButton(
                      label: 'Logout',
                      icon: Icons.logout,
                      color: Colors.white,
                      onPressed: () async => await Auth().signOut(),
                    )
                  else
                    _MenuButton(
                      label: 'Login',
                      icon: Icons.login,
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    label: 'Settings',
                    icon: Icons.settings,
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    label: 'Quit',
                    icon: Icons.exit_to_app,
                    color: Colors.red.shade300,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Quit'),
                          content: const Text('Are you sure you want to exit the game?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Quit', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) SystemNavigator.pop();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        icon: Icon(icon, color: color),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}
