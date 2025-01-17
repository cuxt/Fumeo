import 'package:flutter/material.dart';
import 'package:fumeo/controllers/note.dart';
import 'package:fumeo/pages/note/models/note.dart';
import 'package:fumeo/pages/note/note_edit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// 笔记列表页面
class NoteListView extends StatelessWidget {
  final NoteController noteController = Get.find();

  NoteListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => noteController.isSearching.value
            ? _buildSearchField()
            : Text('我的笔记')),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
                noteController.isSearching.value ? Icons.close : Icons.search)),
            onPressed: () {
              noteController.isSearching.toggle();
              if (!noteController.isSearching.value) {
                noteController.searchQuery.value = '';
                noteController.loadNotes();
              }
            },
          ),
        ],
      ),
      body: Obx(
        () => noteController.notes.isEmpty
            ? _buildEmptyView()
            : _buildNotesList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Get.to(() => NoteEditView()),
      ),
    );
  }

  /// 构建搜索框
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

  /// 构建空视图
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            noteController.searchQuery.isEmpty
                ? '暂无笔记，点击右下角添加'
                : '未找到相关笔记',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 构建笔记列表
  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: noteController.notes.length,
      itemBuilder: (context, index) {
        final note = noteController.notes[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(
              note.title,
              style: TextStyle(fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: _buildPopupMenu(note),
            onTap: () => Get.to(() => NoteEditView(note: note)),
          ),
        );
      },
    );
  }

  /// 构建弹出菜单
  Widget _buildPopupMenu(Note note) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _showDeleteDialog(note);
            break;
          case 'edit':
            Get.to(() => NoteEditView(note: note));
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('编辑'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('删除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  /// 显示删除确认对话框
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
