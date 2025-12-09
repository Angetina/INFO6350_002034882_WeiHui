import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'post_database.dart'; // Post model
import 'post_service.dart'; // Firestore / DB 操作
import 'new_post_activity.dart'; // 新增貼文畫面

class BrowsePostsActivity extends StatefulWidget {
  const BrowsePostsActivity({super.key});

  @override
  State<BrowsePostsActivity> createState() => _BrowsePostsActivityState();
}

class _BrowsePostsActivityState extends State<BrowsePostsActivity> {
  /// 開啟新增貼文頁面
  Future<void> _openNewPost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NewPostActivity()),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('New post added!')));
    }
  }

  /// 真的執行登出
  Future<void> _doSignOut() async {
    await FirebaseAuth.instance.signOut();
    // AuthGate 會監聽 auth 狀態，自動把畫面換回 Login，所以不用自己導航。
  }

  /// 登出前先跳確認視窗
  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      await _doSignOut();
    }
  }

  /// 縮圖
  Widget _buildThumbnail(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image);
        },
      ),
    );
  }

  /// 點某一個貼文 → 詳細頁（用 named route）
  void _openPostDetail(Post post) {
    Navigator.pushNamed(context, '/postDetail', arguments: post);
  }

  /// 刪除貼文（按每一個 ListTile 右邊的 X）
  Future<void> _confirmDelete(Post post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete post'),
          content: Text('Are you sure you want to delete "${post.title}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      try {
        await PostService.deletePost(post.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HyperGarageSale'),
        actions: [
          // 右上角「登出」按鈕
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: PostService.listenPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Tap + to add one!'));
          }

          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final post = posts[index];
              final thumbnailUrl = post.imagePaths.isNotEmpty
                  ? post.imagePaths.first
                  : '';

              return ListTile(
                leading: thumbnailUrl.isNotEmpty
                    ? _buildThumbnail(thumbnailUrl)
                    : const Icon(Icons.image_not_supported),
                title: Text(post.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.price.isNotEmpty) Text('\$${post.price}'),
                    if (post.description.isNotEmpty)
                      Text(
                        post.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                onTap: () => _openPostDetail(post),

                // 每一個貼文右邊的刪除 
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.redAccent,
                  onPressed: () => _confirmDelete(post),
                ),
              );
            },
          );
        },
      ),

      // 只保留右下角這個 + 來新增貼文
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewPost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
