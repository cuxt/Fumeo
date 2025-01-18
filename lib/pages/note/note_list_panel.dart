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
          padding: EdgeInsets.all(8.0),
          child: noteController.isSearching.value
              ? _buildSearchField()
              : Row(
                  children: [
                    Expanded(child: Container()),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => noteController.isSearching.toggle(),
                    ),
                  ],
                ),
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
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: '搜索笔记...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(color: Colors.white),
      onChanged: (value) => noteController.searchNotes(value),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            noteController.searchQuery.isEmpty ? '暂无笔记' : '未找到相关笔记',
            style: TextStyle(color: Colors.grey),
          ),
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
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onTap: () => noteController.selectNote(note),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('删除'),
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
        title: Text('确认删除'),
        content: Text('确定要删除这条笔记吗？'),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text('删除', style: TextStyle(color: Colors.red)),
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
