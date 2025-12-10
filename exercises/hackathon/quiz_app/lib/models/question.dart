import 'package:cloud_firestore/cloud_firestore.dart';

/// 題型：單選 / 多選 / 是非
enum QuestionType {
  single,     // 單選題（只有一個正確答案）
  multiple,   // 多選題（多個正確答案）
  trueFalse,  // 是非題
}

class Question {
  final String id;                  // Firestore document ID（例如 Q1）
  final String question;            // 題目文字
  final QuestionType type;          // 題型
  final List<String> options;       // 選項文字陣列
  final List<int> answer;           // 正確答案索引陣列（0,1,2...）

  Question({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.answer,
  });

  /// 從 Firestore 的 DocumentSnapshot 建立 Question 物件
  factory Question.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Question(
      id: doc.id,
      question: data['question'] as String,
      type: _parseType(data['type'] as String),
      options: List<String>.from(data['options'] ?? []),
      answer: List<int>.from(data['answer'] ?? []),
    );
  }

  /// 把 Firestore 裡的 type 字串轉成 enum
  static QuestionType _parseType(String raw) {
    switch (raw) {
      case 'single':
        return QuestionType.single;
      case 'multiple':
        return QuestionType.multiple;
      case 'true_false':
        return QuestionType.trueFalse;
      default:
        return QuestionType.single; // 預設當作單選，避免 app 爆掉
    }
  }

  // 一些好用的 helper（之後在 QuizPage 會很好用）
  bool get isSingle => type == QuestionType.single;
  bool get isMultiple => type == QuestionType.multiple;
  bool get isTrueFalse => type == QuestionType.trueFalse;
}

