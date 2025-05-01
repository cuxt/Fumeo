import 'package:flutter/material.dart';
import '../models/note_item.dart';

class MarkdownEditor extends StatefulWidget {
  final NoteItem note;
  final Function(String) onTitleChanged;
  final Function(String) onContentChanged;
  final VoidCallback? onSave;

  const MarkdownEditor({
    super.key,
    required this.note,
    required this.onTitleChanged,
    required this.onContentChanged,
    this.onSave,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void didUpdateWidget(covariant MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只有当笔记ID改变时才更新控制器内容
    if (oldWidget.note.id != widget.note.id) {
      _titleController.text = widget.note.title;
      _contentController.text = widget.note.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
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
            onEditingComplete: () {
              // 当标题编辑完成时，自动聚焦到内容输入框
              _contentFocusNode.requestFocus();
            },
          ),
        ),

        // Markdown工具栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildMarkdownToolbar(),
        ),

        // 内容输入框
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              decoration: const InputDecoration(
                labelText: '内容 (支持Markdown格式)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                hintText: '开始编写你的笔记，支持Markdown格式...',
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (value) {
                widget.onContentChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildToolbarButton('标题', '# ', '添加标题'),
          _buildToolbarButton('粗体', '**文本**', '添加粗体文本'),
          _buildToolbarButton('斜体', '*文本*', '添加斜体文本'),
          _buildToolbarButton('列表', '- ', '添加无序列表项'),
          _buildToolbarButton('链接', '[链接文本](URL)', '添加链接'),
          _buildToolbarButton('代码', '`代码`', '添加行内代码'),
          _buildToolbarButton('代码块', '```\n代码\n```', '添加代码块'),
          _buildToolbarButton('引用', '> ', '添加引用'),
          _buildToolbarButton('分隔线', '---', '添加水平分隔线'),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
      String label, String markdownText, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _insertMarkdownText(markdownText),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _insertMarkdownText(String markdownText) {
    // 获取当前光标位置
    final cursorPos = _contentController.selection.start;

    // 获取当前文本
    final text = _contentController.text;

    // 在光标位置插入Markdown文本
    final newText =
        text.substring(0, cursorPos) + markdownText + text.substring(cursorPos);

    // 更新文本控制器
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorPos + markdownText.length,
      ),
    );

    // 触发内容变更事件
    widget.onContentChanged(newText);

    // 保持编辑框焦点
    _contentFocusNode.requestFocus();
  }
}
