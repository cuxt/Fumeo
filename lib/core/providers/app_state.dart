import 'package:flutter/material.dart';
import 'package:fumeo/features/note/providers/note_provider.dart';
import 'package:fumeo/features/todo/providers/todo_provider.dart';

// 全局应用状态管理
class AppState with ChangeNotifier {
  // 笔记管理
  final NoteProvider _noteProvider = NoteProvider();
  NoteProvider get noteProvider => _noteProvider;

  // 待办事项管理
  final TodoProvider _todoProvider = TodoProvider();
  TodoProvider get todoProvider => _todoProvider;

  // 导航状态
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // 构造函数
  AppState();

  // 设置当前导航索引
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
