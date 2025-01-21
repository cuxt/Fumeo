import 'package:flutter/material.dart';
import 'package:fumeo/controllers/note.dart';
import 'package:fumeo/pages/note/models/note.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NoteListPanel extends StatelessWidget {
  final NoteController noteController = Get.find();

  NoteListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() => noteController.isSearching.value
              ? _buildSearchField()
              : Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        noteController.isSearching.value = true;
                      },
                    ),
                  ],
                )),
        ),
        Expanded(
          child: Obx(() => noteController.notes.isEmpty
              ? _buildEmptyList()
              : _buildNotesList()),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '搜索笔记...',
              border: InputBorder.none,
            ),
            onChanged: (value) => noteController.searchNotes(value),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            noteController.isSearching.value = false;
            noteController.searchQuery.value = '';
            noteController.searchNotes('');
          },
        ),
      ],
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.note, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Obx(() => Text(
                noteController.searchQuery.isEmpty ? '暂无笔记' : '未找到相关笔记',
                style: const TextStyle(color: Colors.grey),
              )),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: noteController.notes.length,
      itemBuilder: (context, index) {
        final note = noteController.notes[index];
        return Obx(() => ListTile(
              selected: noteController.selectedNote.value?.id == note.id,
              selectedTileColor: Colors.blue.withAlpha(25),
              title: Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(note.createTime),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onTap: () => noteController.selectNote(note),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('删除'),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(note);
                  }
                },
              ),
            ));
      },
    );
  }

  void _showDeleteDialog(Note note) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条笔记吗？'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('删除', style: TextStyle(color: Colors.red)),
            onPressed: () {
              noteController.deleteNote(note.id);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
