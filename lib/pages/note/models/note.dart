/// 笔记模型类
class Note {
  /// 笔记唯一标识
  final String id;

  /// 笔记标题
  final String title;

  /// 笔记内容
  final String content;

  /// 创建时间
  final DateTime createTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createTime,
  });

  /// 从JSON映射创建Note对象
  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createTime: DateTime.parse(json['createTime']),
  );

  /// 将Note对象转换为JSON映射
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createTime': createTime.toIso8601String(),
  };

  /// 创建Note的副本
  Note copy({
    String? id,
    String? title,
    String? content,
    DateTime? createTime,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        createTime: createTime ?? this.createTime,
      );
}
