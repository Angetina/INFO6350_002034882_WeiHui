import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'quiz_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user != null) ...[
              Text(
                'Hello, ${user.displayName ?? user.email}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: () {
                // 進入測驗頁面（接下來我們會在 QuizPage 實作題目邏輯）
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizPage()),
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
