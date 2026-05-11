import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.green.shade900,
      ),
      backgroundColor: Colors.green.shade800,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('score', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.lightGreenAccent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading leaderboard.\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No scores yet!', style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final username = data['username'] as String? ?? 'Unknown';
              final score = (data['score'] as num?)?.toInt() ?? 0;

              Color rankColor = Colors.white70;
              if (index == 0) rankColor = const Color(0xFFFFD700);
              if (index == 1) rankColor = const Color(0xFFC0C0C0);
              if (index == 2) rankColor = const Color(0xFFCD7F32);

              return ListTile(
                leading: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(username, style: const TextStyle(color: Colors.white)),
                trailing: Text(
                  _formatScore(score),
                  style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000000) return '${(score / 1000000000).toStringAsFixed(1)}B';
    if (score >= 1000000) return '${(score / 1000000).toStringAsFixed(1)}M';
    if (score >= 1000) return '${(score / 1000).toStringAsFixed(1)}K';
    return score.toString();
  }
}
