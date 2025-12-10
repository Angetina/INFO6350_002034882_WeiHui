import 'dart:async';
import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/quiz_service.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizService _quizService = QuizService();

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;

  bool _isLoading = true;

  int? _singleSelectedIndex; // 單選 / 是非
  final Set<int> _multiSelectedIndexes = {}; // 多選

  int _timeLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _quizService.loadQuestions('quiz1');

      questions.shuffle(); // 隨機順序

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      _startTimer(); // 題目載好後開始計時
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('載入題目失敗：$e')));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        _goToResult(timeout: true);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  bool _isCurrentAnswerCorrect() {
    final q = _questions[_currentIndex];

    if (q.type == 'multiple') {
      // 多選：選到的集合要跟正確答案集合完全一樣
      return _multiSelectedIndexes.toSet().containsAll(q.answer) &&
          q.answer.toSet().containsAll(_multiSelectedIndexes);
    }

    // 單選 / 是非
    return q.answer.isNotEmpty && q.answer.first == _singleSelectedIndex;
  }

  void _onNextPressed() {
    if (_isCurrentAnswerCorrect()) {
      _score++;
    }

    if (_currentIndex == _questions.length - 1) {
      _goToResult(timeout: false);
    } else {
      setState(() {
        _currentIndex++;
        _singleSelectedIndex = null;
        _multiSelectedIndexes.clear();
      });
    }
  }

  void _goToResult({required bool timeout}) {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          score: timeout ? 0 : _score,
          total: _questions.length,
          timeout: timeout,
        ),
      ),
    );
  }

  Widget _buildOptions(Question q) {
    if (q.type == 'multiple') {
      // 多選題 → Checkbox
      return Column(
        children: q.options.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;
          final selected = _multiSelectedIndexes.contains(index);

          return CheckboxListTile(
            value: selected,
            title: Text(text),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _multiSelectedIndexes.add(index);
                } else {
                  _multiSelectedIndexes.remove(index);
                }
              });
            },
          );
        }).toList(),
      );
    } else {
      // 單選 / 是非題 → Radio
      return Column(
        children: q.options.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;

          return RadioListTile<int>(
            value: index,
            groupValue: _singleSelectedIndex,
            title: Text(text),
            onChanged: (value) {
              setState(() => _singleSelectedIndex = value);
            },
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('沒有題目')));
    }

    final q = _questions[_currentIndex];
    final isLast = _currentIndex == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上方：題號 + 計時器
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_currentIndex + 1}/${_questions.length}'),
                Text(
                  'Time: $_timeLeft s',
                  style: TextStyle(
                    color: _timeLeft <= 10 ? Colors.red : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 題目文字
            Text(
              q.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // 選項
            Expanded(child: SingleChildScrollView(child: _buildOptions(q))),

            // 下一題 / 完成 按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onNextPressed,
                child: Text(isLast ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
