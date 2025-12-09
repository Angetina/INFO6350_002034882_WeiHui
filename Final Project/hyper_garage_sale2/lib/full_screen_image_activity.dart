import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenImageActivity extends StatelessWidget {
  const FullScreenImageActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final imagePath = ModalRoute.of(context)!.settings.arguments as String;
    final bool isUrl = imagePath.startsWith('http');

    final Widget imageWidget = isUrl
        ? Image.network(imagePath, fit: BoxFit.contain)
        : Image.file(File(imagePath), fit: BoxFit.contain);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Photo', style: TextStyle(color: Colors.white)),
      ),
      body: Center(child: imageWidget),
    );
  }
}
