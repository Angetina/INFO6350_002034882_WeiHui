import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_gate.dart';
import 'browse_posts_activity.dart';
import 'new_post_activity.dart';
import 'post_detail_activity.dart';
import 'full_screen_image_activity.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperGarageSale',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/browse': (context) => const BrowsePostsActivity(),
        '/newPost': (context) => NewPostActivity(),
        '/postDetail': (context) => const PostDetailActivity(),
        '/fullImage': (context) => const FullScreenImageActivity(),
      },
    );
  }
}
