import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_item.dart';

class NoteListItem extends StatelessWidget {
  final NoteItem note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteListItem({
    super.key,
    required this.note,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(note.updatedAt);

    // 从笔记内容中提取摘要
    final summary = _getSummary(note.content);

    return ListTile(
      title: Text(
        note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.titleMedium?.color,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ],
      ),
      selected: isSelected,
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
          : null,
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: () => _confirmDelete(context),
      ),
    );
  }

  // 从内容中提取摘要
  String _getSummary(String content) {
    // 移除Markdown标记
    final plainText = content
        .replaceAll(RegExp(r'#{1,6}\s'), '') // 标题
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // 粗体
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // 斜体
        .replaceAll(RegExp(r'```.*?```', dotAll: true), '') // 代码块
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // 行内代码
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // 链接
        .replaceAll(RegExp(r'!\[(.*?)\]\(.*?\)'), '[图片]') // 图片
        .replaceAll(RegExp(r'^\s*[-+*]\s', multiLine: true), '') // 列表
        .replaceAll(RegExp(r'^\s*\d+\.\s', multiLine: true), ''); // 有序列表

    if (plainText.isEmpty) {
      return '空笔记';
    }

    return plainText.trim();
  }

  // 确认删除对话框
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除笔记"${note.title}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
