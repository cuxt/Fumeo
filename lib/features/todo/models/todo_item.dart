import 'package:flutter/material.dart';

@immutable
class TodoItem {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    this.completed = false,
    required this.createdAt,
  });

  TodoItem copyWith({
    String? title,
    bool? completed,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TodoItem.fromMap(Map<dynamic, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      completed: map['completed'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, completed: $completed, createdAt: $createdAt)';
  }
}
