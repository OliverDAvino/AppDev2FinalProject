import 'package:flutter/material.dart';
import '../managers/achievement_manager.dart';
import '../models/achievement.dart';

// Displays achievement unlock toasts one at a time, draining the manager's queue.
// Must be placed inside a Stack that covers the full screen.
class AchievementToastOverlay extends StatefulWidget {
  final AchievementManager manager;
  const AchievementToastOverlay({required this.manager, super.key});

  @override
  State<AchievementToastOverlay> createState() => _AchievementToastOverlayState();
}

class _AchievementToastOverlayState extends State<AchievementToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Achievement? _current;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    widget.manager.toastTick.addListener(_onNewToast);
  }

  @override
  void dispose() {
    widget.manager.toastTick.removeListener(_onNewToast);
    _controller.dispose();
    super.dispose();
  }

  void _onNewToast() {
    if (!_isShowing) _showNext();
  }

  Future<void> _showNext() async {
    final next = widget.manager.dequeueToast();
    if (next == null) return;
    if (!mounted) return;

    setState(() {
      _current = next;
      _isShowing = true;
    });

    await _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    await _controller.reverse();
    if (!mounted) return;

    setState(() {
      _current = null;
      _isShowing = false;
    });

    // Recursively drain any remaining queued toasts.
    _showNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: _ToastCard(achievement: _current!),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final Achievement achievement;
  const _ToastCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade900.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.lightGreenAccent, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(achievement.icon, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
