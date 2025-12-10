import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final bool timeout;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.timeout,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('results')
          .add({
            'score': widget.timeout ? 0 : widget.score, // 超時不計分
            'total': widget.total,
            'timeout': widget.timeout,
            'createdAt': FieldValue.serverTimestamp(),
          });

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.timeout ? 'Time is up!' : 'Quiz Finished';
    final displayScore = widget.timeout ? 0 : widget.score;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your score: $displayScore / ${widget.total}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              if (widget.timeout)
                const Text(
                  '因為超過時間，本次測驗不計分。',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 24),
              if (_isSaving) const CircularProgressIndicator(),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  '儲存結果失敗：$_error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // 回上一頁（通常是 HomePage）
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
