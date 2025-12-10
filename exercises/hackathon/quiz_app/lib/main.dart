import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart'; // 你之前做的 LoginPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  這裡先用「原生設定檔」初始化（iOS 用 GoogleService-Info.plist）
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // 開 app 先進登入頁
    );
  }
}
