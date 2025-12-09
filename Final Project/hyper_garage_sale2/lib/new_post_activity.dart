import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'post_database.dart';
import 'post_service.dart';

class NewPostActivity extends StatefulWidget {
  const NewPostActivity({super.key});

  @override
  State<NewPostActivity> createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 本機圖片路徑
  final List<String> _imagePaths = [];

  
  // 選照片
  
  Future<void> _pickImage() async {
    if (_imagePaths.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can attach up to 4 images only.')),
      );
      return;
    }

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (photo != null) {
      setState(() {
        _imagePaths.add(photo.path);
      });
    }
  }

  
  // 上傳圖片，拿到下載網址
  
  Future<List<String>> _uploadImagesAndGetUrls() async {
    final List<String> downloadUrls = [];

    for (int i = 0; i < _imagePaths.length; i++) {
      final file = File(_imagePaths[i]);
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      final ref = _storage.ref().child('post_images').child(fileName);

      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  
  // 按下「Post a new classified」
  
  Future<void> _postClassified() async {
    final messenger = ScaffoldMessenger.of(context);

    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    try {
      // （可選）先提示正在上傳
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Uploading post...')),
      );

      // 1. 上傳圖片
      final imageUrls = await _uploadImagesAndGetUrls();

      // 2. 寫入 Firestore
      final post = Post(
        title: title,
        price: price,
        description: description,
        imagePaths: imageUrls,
      );
      await PostService.addPost(post);

      if (!mounted) return;

      // 3. 在「目前這一頁」顯示成功的 SnackBar
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('New post added: $title (\$$price)')),
      );

      // 4. 清空表單，讓你可以繼續新增下一筆
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _imagePaths.clear();
      });

    
      // Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text('Failed to post: $e')));
    }
  }

  Widget _buildImageThumbnail(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(File(path), width: 72, height: 72, fit: BoxFit.cover),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HyperGarageSale - New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title'),
            const SizedBox(height: 4),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Price'),
            const SizedBox(height: 4),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Description'),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Photos (up to 4)'),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagePaths.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final path = _imagePaths[index];
                        return Stack(
                          children: [
                            _buildImageThumbnail(path),
                            Positioned(
                              right: -8,
                              top: -8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _imagePaths.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _postClassified, 
                child: const Text('Post a new classified'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
