import 'package:cloud_firestore/cloud_firestore.dart';

import 'post_database.dart';

class PostService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _postsCol =>
      _db.collection('posts');

  /// 新增貼文
  static Future<void> addPost(Post post) async {
    final data = post.toMap()
      ..['createdAt'] =
          FieldValue.serverTimestamp(); // 多存一個 createdAt，方便排序（沒有也可以）

    await _postsCol.add(data);
  }

  /// 監聽所有貼文
  static Stream<List<Post>> listenPosts() {
    return _postsCol.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post.fromMap(data, doc.id); // 這裡把 doc.id 存進 Post.id
      }).toList();
    });
  }

  /// 刪除一筆貼文
  static Future<void> deletePost(String postId) async {
    await _postsCol.doc(postId).delete();
  }
}
