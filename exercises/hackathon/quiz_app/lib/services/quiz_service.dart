import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 載入某個 quiz 的所有問題
  /// quizId 目前可以傳 'quiz1'
  Future<List<Question>> loadQuestions(String quizId) async {
    final QuerySnapshot snapshot = await _db
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();

    return snapshot.docs.map((doc) => Question.fromDoc(doc)).toList();
  }
}
