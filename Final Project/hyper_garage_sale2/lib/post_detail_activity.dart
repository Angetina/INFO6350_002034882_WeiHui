import 'dart:io';

import 'package:flutter/material.dart';

import 'post_database.dart';

class PostDetailActivity extends StatelessWidget {
  const PostDetailActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! Post) {
      return const Scaffold(
        body: Center(child: Text('No post data to display')),
      );
    }

    final Post post = args;

    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (post.price.isNotEmpty) ...[
              Text(
                'Price: \$${post.price}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Description:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(post.description),
            const SizedBox(height: 16),
            if (post.imagePaths.isNotEmpty) ...[
              const Text(
                'Photos:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.imagePaths.map((path) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/fullImage',
                        arguments: path,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildThumbnail(path),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String path) {
    final bool isUrl = path.startsWith('http');

    if (isUrl) {
      return Image.network(
        path,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 100,
            height: 100,
            child: Center(child: Icon(Icons.broken_image)),
          );
        },
      );
    } else {
      return Image.file(
        File(path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 100,
            height: 100,
            child: Center(child: Icon(Icons.broken_image)),
          );
        },
      );
    }
  }
}
