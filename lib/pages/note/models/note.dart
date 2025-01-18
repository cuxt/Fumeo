class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createTime;
  final int wordCount;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createTime,
    required this.wordCount,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        createTime: DateTime.parse(json['createTime']),
        wordCount: json['wordCount'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createTime': createTime.toIso8601String(),
        'wordCount': wordCount,
      };

  Note copy({
    String? id,
    String? title,
    String? content,
    DateTime? createTime,
    int? wordCount,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        createTime: createTime ?? this.createTime,
        wordCount: wordCount ?? this.wordCount,
      );
}
