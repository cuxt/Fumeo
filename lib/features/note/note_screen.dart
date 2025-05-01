import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'widgets/note_list_item.dart';
import 'widgets/markdown_editor.dart';
import 'widgets/markdown_preview.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  bool _isPreviewMode = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: Consumer<NoteProvider>(
        builder: (context, noteProvider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('笔记'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                // 添加新笔记按钮
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => noteProvider.addNote(),
                ),
                // 预览/编辑模式切换按钮
                if (noteProvider.selectedNote != null)
                  IconButton(
                    icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPreviewMode = !_isPreviewMode;
                      });
                    },
                  ),
              ],
            ),
            body: _buildBody(context, noteProvider),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, NoteProvider noteProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    // 宽屏时分为两列，窄屏时用底部导航栏切换
    if (isWideScreen) {
      return Row(
        children: [
          // 左侧笔记列表
          SizedBox(
            width: 280,
            child: _buildNotesList(noteProvider),
          ),

          // 分隔线
          const VerticalDivider(width: 1),

          // 右侧编辑/预览区
          Expanded(
            child: _buildEditArea(noteProvider),
          ),
        ],
      );
    } else {
      return noteProvider.notes.isEmpty
          ? _buildEmptyState()
          : _buildEditArea(noteProvider);
    }
  }

  Widget _buildNotesList(NoteProvider noteProvider) {
    final notes = noteProvider.notes;
    final selectedNote = noteProvider.selectedNote;

    if (notes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // 笔记列表标题
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          alignment: Alignment.centerLeft,
          child: Text(
            '笔记列表 (${notes.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // 笔记列表
        Expanded(
          child: ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteListItem(
                note: note,
                isSelected: selectedNote?.id == note.id,
                onTap: () => noteProvider.selectNote(note.id),
                onDelete: () => noteProvider.deleteNote(note.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditArea(NoteProvider noteProvider) {
    final selectedNote = noteProvider.selectedNote;

    if (selectedNote == null) {
      return const Center(
        child: Text('选择或创建一个笔记开始编辑'),
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
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无笔记',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角"+"按钮创建新笔记',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
