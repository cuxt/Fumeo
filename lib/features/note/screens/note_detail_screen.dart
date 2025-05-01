import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/markdown_editor.dart';
import '../widgets/markdown_preview.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool _isPreviewMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 确保在初始化时选择正确的笔记
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      noteProvider.selectNote(widget.noteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final selectedNote = noteProvider.selectedNote;

        return Scaffold(
          appBar: AppBar(
            title: Text(selectedNote?.title ?? '加载中...'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // 返回时清除选中状态，但不清除实际的选中笔记数据
                Navigator.pop(context);
              },
            ),
            actions: [
              // 保存按钮
              if (selectedNote != null && !_isPreviewMode)
                _isSaving
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save),
                        tooltip: '保存笔记',
                        onPressed: () => _saveNote(context, noteProvider),
                      ),
              // 预览/编辑模式切换按钮
              if (selectedNote != null)
                IconButton(
                  icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
                  tooltip: _isPreviewMode ? '编辑模式' : '预览模式',
                  onPressed: () {
                    setState(() {
                      _isPreviewMode = !_isPreviewMode;
                    });
                  },
                ),
            ],
          ),
          body: _buildContent(noteProvider),
        );
      },
    );
  }

  Widget _buildContent(NoteProvider noteProvider) {
    final selectedNote = noteProvider.selectedNote;

    if (selectedNote == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return _isPreviewMode
        ? MarkdownPreview(markdownData: selectedNote.content)
        : MarkdownEditor(
            note: selectedNote,
            onTitleChanged: (title) => noteProvider.updateNote(
              id: selectedNote.id,
              title: title,
            ),
            onContentChanged: (content) => noteProvider.updateNote(
              id: selectedNote.id,
              content: content,
            ),
            onSave: () => _saveNote(context, noteProvider),
          );
  }

  Future<void> _saveNote(
      BuildContext context, NoteProvider noteProvider) async {
    final selectedNote = noteProvider.selectedNote;
    if (selectedNote == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 这里已经通过onChange事件保存了内容，此处仅显示保存成功提示
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟保存操作

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('笔记已保存'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
