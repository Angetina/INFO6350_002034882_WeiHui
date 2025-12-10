import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as g; // ★ 加 as g
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main_screen.dart';

class SignInScreen extends StatelessWidget {
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 1️⃣ 用套件裡的 GoogleSignIn（加了 g. 前綴）
      final g.GoogleSignIn googleSignIn = g.GoogleSignIn();
      final g.GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return; // 使用者取消登入

      // 2️⃣ 取得 Google token
      final g.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ 轉成 Firebase Auth 的憑證
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ 登入 Firebase Auth
      final UserCredential userCred = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCred.user;

      // 5️⃣ 寫入 Firestore 的 users collection
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        await userDoc.set({
          'uid': user.uid,
          'displayName': user.displayName ?? user.email ?? 'No Name',
          'email': user.email,
          'photoURL': user.photoURL,
          'lastSignInAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 6️⃣ 進入主畫面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signInWithGoogle(context),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
