// lib/guest_book.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'guest_book_message.dart';
import 'src/widgets.dart';

class GuestBook extends StatefulWidget {
  const GuestBook({
    super.key,
    required this.addMessage,
    required this.messages, // ✅ 這裡一定要有 messages
  });

  // 新增留言時要呼叫的 callback
  final FutureOr<void> Function(String message) addMessage;

  // 要顯示在畫面上的留言列表
  final List<GuestBookMessage> messages; // ✅ 型別與名稱都要一樣

  @override
  _GuestBookState createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 輸入框 + SEND 按鈕
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Leave a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                StyledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                      Text('SEND'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ✅ 把每一筆 GuestBookMessage 顯示出來
        for (var message in widget.messages)
          Paragraph('${message.name}: ${message.message}'),

        const SizedBox(height: 8),
      ],
    );
  }
}
