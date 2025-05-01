import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'widgets/note_list_item.dart';
import 'screens/note_detail_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final NoteProvider _noteProvider = NoteProvider();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _noteProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('笔记'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            // 添加新笔记按钮
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '新建笔记',
              onPressed: _createNewNote,
            ),
            // 刷新按钮
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
              onPressed: _refreshNotes,
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  void _createNewNote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newNote = await _noteProvider.addNote();

      if (mounted) {
        // 导航到笔记详情页
        _navigateToNoteDetail(newNote.id);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _refreshNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _noteProvider.refreshNotes();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToNoteDetail(String noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _noteProvider,
          child: NoteDetailScreen(noteId: noteId),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        if (noteProvider.isLoading || _isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final notes = noteProvider.notes;
        if (notes.isEmpty) {
          return _buildEmptyState();
        }

        return _buildNotesList(noteProvider);
      },
    );
  }

  Widget _buildNotesList(NoteProvider noteProvider) {
    final notes = noteProvider.notes;

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
                isSelected: false, // 在主列表页不显示选中状态
                onTap: () => _navigateToNoteDetail(note.id),
                onDelete: () async {
                  await noteProvider.deleteNote(note.id);
                },
              );
            },
          ),
        ),
      ],
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewNote,
            icon: const Icon(Icons.add),
            label: const Text('创建新笔记'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
