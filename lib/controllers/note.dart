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

  late PageController pageController;

  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    loadNotes();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void selectNote(Note note) {
    selectedNote.value = note;
    currentView.value = 1; // 切换到编辑视图
    isEditing.value = false; // 选择笔记时，重置编辑状态
    jumpToPage(1);
  }

  void jumpToPage(int page) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void createNewNote() {
    // 如果当前正在编辑且内容未保存
    if (isEditing.value) {
      _showUnsavedChangesDialog(() {
        _createNew();
      });
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
    isEditing.value = true; // 创建新笔记时，设置为编辑状态
    jumpToPage(1);
  }

  // 保存前确认对话框
  void _showUnsavedChangesDialog(VoidCallback onContinue) {
    Get.dialog(
      AlertDialog(
        title: const Text('创建新笔记'),
        content: const Text('当前笔记未保存，是否继续？'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('继续'),
            onPressed: () {
              Get.back();
              onContinue();
            },
          ),
        ],
      ),
    );
  }

  Future<void> loadNotes() async {
    try {
      final notesList = await _databaseService.readAllNotes();
      notes.assignAll(notesList);

      // 如果当前没有选中的笔记，并且列表不为空，默认选中第一条
      if (selectedNote.value == null && notes.isNotEmpty) {
        selectedNote.value = notes.first;
      }
      // 如果列表为空，清空选中
      if (notes.isEmpty) {
        selectedNote.value = null;
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
      isEditing.value = false; // 添加笔记后，重置编辑状态
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
      isEditing.value = false; // 更新笔记后，重置编辑状态
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
    searchQuery.value = query;
    try {
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
