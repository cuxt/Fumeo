import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';

class TodoProvider extends ChangeNotifier {
  final List<TodoItem> _items = [];
  final Box _box = Hive.box('todo_box');

  List<TodoItem> get items => _items;

  TodoProvider() {
    _loadTodos();
  }

  // 从Hive加载待办事项
  void _loadTodos() {
    final todoMaps = _box.get('todos', defaultValue: []);
    if (todoMaps is List) {
      _items.clear();
      for (final item in todoMaps) {
        if (item is Map) {
          _items.add(TodoItem.fromMap(item));
        }
      }
      _sortItems();
      notifyListeners();
    }
  }

  // 保存待办事项到Hive
  void _saveTodos() {
    _box.put('todos', _items.map((item) => item.toMap()).toList());
  }

  // 添加新的待办事项
  void addTodo(String title) {
    if (title.isEmpty) return;

    final newTodo = TodoItem(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
    );

    _items.add(newTodo);
    _sortItems();
    _saveTodos();
    notifyListeners();
  }

  // 更新待办事项状态
  void toggleTodoStatus(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].completed = !_items[index].completed;
      _sortItems();
      _saveTodos();
      notifyListeners();
    }
  }

  // 编辑待办事项内容
  void editTodo(String id, String title) {
    if (title.isEmpty) return;

    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(title: title);
      _saveTodos();
      notifyListeners();
    }
  }

  // 删除待办事项
  void deleteTodo(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveTodos();
    notifyListeners();
  }

  // 对待办事项排序 - 未完成的在前面，按创建时间排序
  void _sortItems() {
    _items.sort((a, b) {
      if (a.completed == b.completed) {
        return b.createdAt.compareTo(a.createdAt); // 新创建的在前
      }
      return a.completed ? 1 : -1; // 未完成的在前面
    });
  }
}
