import 'package:flutter/material.dart';
import 'package:fumeo/pages/note/database/database.dart';
import 'package:fumeo/pages/note/models/note.dart';
import 'package:get/get.dart';

class NoteController extends GetxController {
  var notes = <Note>[].obs;
  var searchQuery = ''.obs;
  var isSearching = false.obs;
  Rx<Note?> selectedNote = Rx<Note?>(null);
  var currentView = 0.obs; // 0:笔记，1:编辑
  var isEditing = false.obs;

  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  void selectNote(Note note) {
    selectedNote.value = note;
    currentView.value = 1; // 切换到编辑视图
  }

  void createNewNote() {
    // 如果正在编辑且内容未保存
    if (isEditing.value) {
      Get.dialog(
        AlertDialog(
          title: Text('创建新笔记'),
          content: Text('当前笔记未保存，是否继续？'),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text('继续'),
              onPressed: () {
                Get.back();
                _createNew();
              },
            ),
          ],
        ),
      );
    } else {
      _createNew();
    }
  }

  void _createNew() {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      createTime: DateTime.now(),
      wordCount: 0,
    );
    selectedNote.value = note;
    currentView.value = 1;
    isEditing.value = false;
  }

  Future<void> loadNotes() async {
    try {
      final notesList = await _databaseService.readAllNotes();
      notes.assignAll(notesList);
      if (notes.isNotEmpty && selectedNote.value == null) {
        selectedNote.value = notes.first;
      }
    } catch (e) {
      Get.snackbar('错误', '加载笔记失败: ${e.toString()}');
    }
  }

  Future<void> addNote(String title, String content, int wordCount) async {
    try {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createTime: DateTime.now(),
        wordCount: wordCount,
      );
      await _databaseService.create(note);
      await loadNotes();
      selectedNote.value = note;
    } catch (e) {
      Get.snackbar('错误', '添加笔记失败: ${e.toString()}');
    }
  }

  Future<void> updateNote(
      String id, String title, String content, int wordCount) async {
    try {
      final note = Note(
        id: id,
        title: title,
        content: content,
        createTime: DateTime.now(),
        wordCount: wordCount,
      );
      await _databaseService.update(note);
      await loadNotes();
      selectedNote.value = note;
    } catch (e) {
      Get.snackbar('错误', '更新笔记失败: ${e.toString()}');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _databaseService.delete(id);
      if (selectedNote.value?.id == id) {
        selectedNote.value = null;
      }
      await loadNotes();
    } catch (e) {
      Get.snackbar('错误', '删除笔记失败: ${e.toString()}');
    }
  }

  Future<void> searchNotes(String query) async {
    try {
      searchQuery.value = query;
      if (query.isEmpty) {
        await loadNotes();
        return;
      }
      final searchResults = await _databaseService.searchNotes(query);
      notes.assignAll(searchResults);
    } catch (e) {
      Get.snackbar('错误', '搜索笔记失败: ${e.toString()}');
    }
  }
}
