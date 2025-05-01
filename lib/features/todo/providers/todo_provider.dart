import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';

class TodoProvider extends ChangeNotifier {
  final List<TodoItem> _items = [];
  final Box _box = Hive.box('todo_box');
  bool _isLoading = false;

  List<TodoItem> get items => _items;
  bool get isLoading => _isLoading;

  TodoProvider() {
    _loadTodos();
  }

  // 从Hive加载待办事项
  Future<void> _loadTodos() async {
    try {
      _isLoading = true;
      notifyListeners();

      final todoMaps = _box.get('todos', defaultValue: []);
      if (todoMaps is List) {
        _items.clear();
        for (final item in todoMaps) {
          if (item is Map) {
            _items.add(TodoItem.fromMap(item));
          }
        }
        _sortItems();
      }
    } catch (e) {
      debugPrint('加载待办事项失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 保存待办事项到Hive
  Future<void> _saveTodos() async {
    try {
      await _box.put('todos', _items.map((item) => item.toMap()).toList());
    } catch (e) {
      debugPrint('保存待办事项失败: $e');
    }
  }

  // 添加新的待办事项
  Future<TodoItem> addTodo(String title) async {
    if (title.isEmpty) throw ArgumentError('待办事项标题不能为空');

    _isLoading = true;
    notifyListeners();

    try {
      final newTodo = TodoItem(
        id: const Uuid().v4(),
        title: title,
        createdAt: DateTime.now(),
      );

      _items.add(newTodo);
      _sortItems();
      await _saveTodos();

      return newTodo;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新待办事项状态
  Future<void> toggleTodoStatus(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updatedItem = _items[index].copyWith(
        completed: !_items[index].completed,
      );
      _items[index] = updatedItem;
      _sortItems();
      await _saveTodos();
      notifyListeners();
    }
  }

  // 编辑待办事项内容
  Future<void> editTodo(String id, String title) async {
    if (title.isEmpty) return;

    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(title: title);
      await _saveTodos();
      notifyListeners();
    }
  }

  // 删除待办事项
  Future<void> deleteTodo(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveTodos();
    notifyListeners();
  }

  // 清除所有已完成的待办事项
  Future<void> clearCompletedTodos() async {
    _items.removeWhere((item) => item.completed);
    await _saveTodos();
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

  // 刷新待办事项列表
  Future<void> refreshTodos() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 保存当前项目的状态（主要是已完成状态）
      final Map<String, bool> completionStatus = {};
      for (final item in _items) {
        completionStatus[item.id] = item.completed;
      }

      // 从存储加载数据
      final todoMaps = _box.get('todos', defaultValue: []);
      if (todoMaps is List) {
        _items.clear();
        for (final item in todoMaps) {
          if (item is Map) {
            final todoItem = TodoItem.fromMap(item);
            // 恢复之前的完成状态（如果存在）
            if (completionStatus.containsKey(todoItem.id)) {
              final wasCompleted = completionStatus[todoItem.id]!;
              if (wasCompleted != todoItem.completed) {
                _items.add(todoItem.copyWith(completed: wasCompleted));
                continue;
              }
            }
            _items.add(todoItem);
          }
        }
        // 排序并保存（确保状态一致性）
        _sortItems();
        await _saveTodos();
      }
    } catch (e) {
      debugPrint('刷新待办事项失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取统计信息
  Map<String, int> getStats() {
    final total = _items.length;
    final completed = _items.where((item) => item.completed).length;
    final pending = total - completed;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }
}
