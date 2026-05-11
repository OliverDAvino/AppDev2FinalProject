import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _controller = TextEditingController();
  String? _currentUsername;
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final username = await _userService.getUsername(email);
    if (mounted) {
      setState(() {
        _currentUsername = username;
        _controller.text = username ?? '';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final newUsername = _controller.text.trim();
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null) return;
    if (newUsername == _currentUsername) return;

    if (newUsername.length < 3) {
      setState(() => _errorMessage = 'Username must be at least 3 characters.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final taken = await _userService.isUsernameTaken(newUsername)
          .timeout(const Duration(seconds: 10));
      if (taken) {
        setState(() {
          _errorMessage = 'Username is already taken.';
          _saving = false;
        });
        return;
      }

      if (_currentUsername != null) {
        await _userService.updateUsername(email, _currentUsername!, newUsername)
            .timeout(const Duration(seconds: 10));
      } else {
        await _userService.createUsername(email, newUsername)
            .timeout(const Duration(seconds: 10));
      }
      setState(() {
        _currentUsername = newUsername;
        _successMessage = 'Username updated!';
        _saving = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not connect to server. Check your connection and try again.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green.shade900,
      ),
      backgroundColor: Colors.green.shade800,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.lightGreenAccent))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 28),
                  const Text('Username', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.person, color: Colors.lightGreenAccent),
                      filled: true,
                      fillColor: Colors.green.shade900,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.lightGreenAccent, width: 2),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                  if (_successMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_successMessage!, style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.lightGreenAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.lightGreenAccent)
                          : const Text('Save Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
