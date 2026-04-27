import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import '../firebase/save_service.dart';
import 'main_menu_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) await onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green.shade900,
      ),
      backgroundColor: Colors.green.shade800,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Return to Main Menu
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Return to Main Menu', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainMenuScreen()),
              (_) => false,
            ),
          ),
          const Divider(color: Colors.white24),

          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.data == null) return const SizedBox.shrink();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      await Auth().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                          (_) => false,
                        );
                      }
                    },
                  ),
                  const Divider(color: Colors.white24),
                ],
              );
            },
          ),

          // Reset
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.orange),
            title: const Text('Reset Progress', style: TextStyle(color: Colors.orange)),
            onTap: () => _confirm(
              context,
              title: 'Reset Progress',
              message: 'This will permanently delete all your cookies and upgrades. Are you sure?',
              confirmLabel: 'Reset',
              confirmColor: Colors.orange,
              onConfirm: () async {
                final email = FirebaseAuth.instance.currentUser?.email;
                if (email != null) {
                  await SaveService().deleteSave(email);
                }
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                    (_) => false,
                  );
                }
              },
            ),
          ),
          const Divider(color: Colors.white24),

          // Exit
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Exit Game', style: TextStyle(color: Colors.red)),
            onTap: () => _confirm(
              context,
              title: 'Exit Game',
              message: 'Are you sure you want to close the game?',
              confirmLabel: 'Exit',
              confirmColor: Colors.red,
              onConfirm: () async => SystemNavigator.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
