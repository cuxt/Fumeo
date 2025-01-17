import 'package:fumeo/pages/note/database/database.dart';
import 'package:fumeo/pages/note/models/note.dart';
import 'package:get/get.dart';

/// 笔记控制器类
class NoteController extends GetxController {
  // 笔记列表observable
  var notes = <Note>[].obs;

  // 搜索关键词observable
  var searchQuery = ''.obs;

  // 是否正在搜索observable
  var isSearching = false.obs;

  // 数据库服务实例
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  /// 加载所有笔记
  Future<void> loadNotes() async {
    try {
      final notesList = await _databaseService.readAllNotes();
      notes.assignAll(notesList);
    } catch (e) {
      Get.snackbar('错误', '加载笔记失败: ${e.toString()}');
    }
  }

  /// 添加笔记
  Future<void> addNote(String title, String content) async {
    try {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createTime: DateTime.now(),
      );
      await _databaseService.create(note);
      await loadNotes();
    } catch (e) {
      Get.snackbar('错误', '添加笔记失败: ${e.toString()}');
    }
  }

  /// 更新笔记
  Future<void> updateNote(String id, String title, String content) async {
    try {
      final note = Note(
        id: id,
        title: title,
        content: content,
        createTime: DateTime.now(),
      );
      await _databaseService.update(note);
      await loadNotes();
    } catch (e) {
      Get.snackbar('错误', '更新笔记失败: ${e.toString()}');
    }
  }

  /// 删除笔记
  Future<void> deleteNote(String id) async {
    try {
      await _databaseService.delete(id);
      await loadNotes();
    } catch (e) {
      Get.snackbar('错误', '删除笔记失败: ${e.toString()}');
    }
  }

  /// 搜索笔记
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
