import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note_item.dart';

class NoteProvider extends ChangeNotifier {
  final List<NoteItem> _notes = [];
  final Box _box = Hive.box('notes_box');
  NoteItem? _selectedNote;
  bool _isLoading = false;

  List<NoteItem> get notes => _notes;
  NoteItem? get selectedNote => _selectedNote;
  bool get isLoading => _isLoading;

  NoteProvider() {
    _loadNotes();
  }

  // 从Hive加载笔记
  Future<void> _loadNotes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final noteMaps = _box.get('notes', defaultValue: []);
      if (noteMaps is List) {
        _notes.clear();
        for (final item in noteMaps) {
          if (item is Map) {
            _notes.add(NoteItem.fromMap(item));
          }
        }
        _sortNotes();
      }
    } catch (e) {
      debugPrint('加载笔记失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 保存笔记到Hive
  Future<void> _saveNotes() async {
    try {
      await _box.put('notes', _notes.map((item) => item.toMap()).toList());
    } catch (e) {
      debugPrint('保存笔记失败: $e');
    }
  }

  // 添加新笔记
  Future<NoteItem> addNote({String title = '新笔记', String content = ''}) async {
    final now = DateTime.now();
    final newNote = NoteItem(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    _notes.add(newNote);
    _selectedNote = newNote;
    _sortNotes();
    await _saveNotes();
    notifyListeners();
    return newNote;
  }

  // 更新笔记内容
  Future<void> updateNote({
    required String id,
    String? title,
    String? content,
  }) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final now = DateTime.now();
      _notes[index] = _notes[index].copyWith(
        title: title,
        content: content,
        updatedAt: now,
      );

      if (_selectedNote?.id == id) {
        _selectedNote = _notes[index];
      }

      _sortNotes();
      await _saveNotes();
      notifyListeners();
    }
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);

    if (_selectedNote?.id == id) {
      _selectedNote = _notes.isNotEmpty ? _notes[0] : null;
    }

    await _saveNotes();
    notifyListeners();
  }

  // 选择当前笔记
  void selectNote(String id) {
    // 尝试根据ID查找笔记
    final noteIndex = _notes.indexWhere((note) => note.id == id);

    if (noteIndex != -1) {
      // 如果找到了笔记，选中它
      _selectedNote = _notes[noteIndex];
      notifyListeners();
    } else if (_notes.isNotEmpty) {
      // 如果没找到指定ID的笔记但列表不为空，选择第一个笔记
      _selectedNote = _notes[0];
      notifyListeners();
    } else {
      // 如果笔记列表为空，创建一个新笔记
      addNote();
    }
  }

  // 清除当前选中的笔记
  void clearSelectedNote() {
    _selectedNote = null;
    notifyListeners();
  }

  // 按更新时间排序笔记
  void _sortNotes() {
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // 刷新笔记列表
  Future<void> refreshNotes() async {
    await _loadNotes();
  }
}
