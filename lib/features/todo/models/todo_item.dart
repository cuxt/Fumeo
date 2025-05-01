class TodoItem {
  final String id;
  final String title;
  bool completed;
  final DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    this.completed = false,
    required this.createdAt,
  });

  // 从Hive存储中的Map创建TodoItem
  factory TodoItem.fromMap(Map<dynamic, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      completed: map['completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // 将TodoItem转换为可存储的Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 创建TodoItem的副本
  TodoItem copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
