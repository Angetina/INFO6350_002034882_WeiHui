import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as g; // ★ 也加 as g

import 'game_list_screen.dart';
import 'leaderboard_list_screen.dart';

class MainScreen extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      await g.GoogleSignIn().signOut(); // ★ 用 g.GoogleSignIn()
      await FirebaseAuth.instance.signOut();
      // authStateChanges 會自動把畫面導回登入
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Games'),
              Tab(text: 'Leaderboard'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _signOut(context),
            ),
          ],
        ),
        body: TabBarView(children: [GameListScreen(), LeaderboardListScreen()]),
      ),
    );
  }
}
