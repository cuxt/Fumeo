import 'package:flutter/material.dart';
import '../models/note_item.dart';

class MarkdownEditor extends StatefulWidget {
  final NoteItem note;
  final Function(String) onTitleChanged;
  final Function(String) onContentChanged;

  const MarkdownEditor({
    super.key,
    required this.note,
    required this.onTitleChanged,
    required this.onContentChanged,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void didUpdateWidget(covariant MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _titleController.text = widget.note.title;
      _contentController.text = widget.note.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题输入框
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '标题',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            onChanged: widget.onTitleChanged,
          ),
        ),

        // 内容输入框
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '内容 (支持Markdown格式)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: widget.onContentChanged,
            ),
          ),
        ),
      ],
    );
  }
}
