// lib/app_state.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'guest_book_message.dart';

/// 出席狀態：未知 / 會去 / 不會去
enum Attending { unknown, yes, no }

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    _init();
  }

  // ===== 共用狀態 =====
  bool _initialized = false;
  bool get initialized => _initialized;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  // ===== Guestbook 狀態 =====
  final List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  // ===== RSVP 狀態 =====
  int _attendees = 0; // 目前有幾個人會來
  int get attendees => _attendees;

  Attending _attending = Attending.unknown; // 我自己的出席狀態
  Attending get attending => _attending;

  // ===== 各種監聽 =====
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _attendeesSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _attendingSubscription;

  // ================= init =================
  Future<void> _init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    // 1. 監聽「所有正在出席的人」→ 更新 _attendees
    _attendeesSubscription = FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          _attendees = snapshot.docs.length;
          notifyListeners();
        });

    // 2. 監聽登入狀態
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        // ===== 使用者登入 =====
        _loggedIn = true;

        // 2-1. 監聽 guestbook → 更新留言列表
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
              _guestBookMessages.clear();
              for (final doc in snapshot.docs) {
                _guestBookMessages.add(
                  GuestBookMessage(
                    name: doc.data()['name'] as String,
                    message: doc.data()['text'] as String,
                  ),
                );
              }
              notifyListeners();
            });

        // 2-2. 監聽「自己這一筆 attendee 文件」→ 更新 _attending
        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
              if (!snapshot.exists) {
                _attending = Attending.unknown;
              } else {
                final data = snapshot.data();
                final attendingFlag = (data?['attending'] as bool?) ?? false;
                _attending = attendingFlag ? Attending.yes : Attending.no;
              }
              notifyListeners();
            });
      } else {
        // ===== 使用者登出 =====
        _loggedIn = false;

        _guestBookMessages.clear();
        _guestBookSubscription?.cancel();

        _attending = Attending.unknown;
        _attendingSubscription?.cancel();

        notifyListeners();
      }
    });

    _initialized = true;
    notifyListeners();
  }

  // ================= Guestbook：寫入留言 =================
  Future<void> addMessageToGuestBook(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be logged in to write a message.');
    }

    await FirebaseFirestore.instance.collection('guestbook').add({
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': user.displayName ?? user.email,
      'userId': user.uid,
    });
  }

  // ================= RSVP：設定出席狀態 =================
  Future<void> setAttending(Attending attending) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User must be logged in to RSVP.');
    }

    await FirebaseFirestore.instance.collection('attendees').doc(user.uid).set(
      <String, dynamic>{'attending': attending == Attending.yes},
    );
  }

  // ================= 清理 =================
  @override
  void dispose() {
    _authSubscription?.cancel();
    _guestBookSubscription?.cancel();
    _attendeesSubscription?.cancel();
    _attendingSubscription?.cancel();
    super.dispose();
  }
}
