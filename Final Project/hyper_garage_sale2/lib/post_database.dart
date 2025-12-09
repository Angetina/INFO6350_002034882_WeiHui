class Post {
  /// Firestore 的 document id，用來刪除 / 更新
  final String id;
  final String title;
  final String price;
  final String description;

  /// 存 Firebase Storage 下載網址
  final List<String> imagePaths;

  Post({
    this.id = '',
    required this.title,
    required this.price,
    required this.description,
    required this.imagePaths,
  });

  /// 存到 Firestore 用
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'imagePaths': imagePaths,
    };
  }

  /// 從 Firestore 讀回來
  factory Post.fromMap(Map<String, dynamic> data, String id) {
    return Post(
      id: id,
      title: data['title'] as String? ?? '',
      price: data['price'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imagePaths: (data['imagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
    );
  }
}
