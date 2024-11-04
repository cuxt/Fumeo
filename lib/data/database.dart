import 'package:hive_ce_flutter/hive_flutter.dart';

class TodoDataBase {
  List todoList = [];
  final _todoBox = Hive.box('todo_box');

  // 第一次启动时初始化数据
  void createInitialData() {
    todoList = [
      ['数据结构', false],
      ['计算机组成原理', false],
      ['操作系统', false],
      ['计算机网络', false],
    ];
  }

  // 加载数据
  void loadData() {
    todoList = _todoBox.get('TODOLIST');
  }

  // 更新数据
  void updateDataBase() {
    _todoBox.put('TODOLIST', todoList);
  }
}
