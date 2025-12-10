import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google 登入
  Future<User?> signInWithGoogle() async {
    try {
      //  Web：用 Firebase 的 Google Provider（官方建議）
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();

        final UserCredential userCredential = await _auth.signInWithPopup(
          googleProvider,
        );

        return userCredential.user;
      }

      //  Android / iOS / macOS：用 google_sign_in v7 新版寫法
      // 1. 初始化
      await GoogleSignIn.instance.initialize();

      // 2. 觸發登入流程（取代舊的 signIn()）
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        // 使用者按了取消
        return null;
      }

      // 3. 取得 token（新版是同步屬性，不能再 await）
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. 建立 Firebase 憑證（新版文件只用 idToken 就夠）:contentReference[oaicite:1]{index=1}
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken 在 v7 上很多平台拿不到，就先不填
      );

      // 5. 用 Firebase Auth 登入
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      // 這裡你可以改成丟出錯誤或記 log
      // print('Google sign in error: $e');
      rethrow;
    }
  }

  /// 登出（Web 不需要 google_sign_in 登出）
  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
