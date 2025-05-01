import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note_item.dart';

class NoteProvider extends ChangeNotifier {
  final List<NoteItem> _notes = [];
  final Box _box = Hive.box('notes_box');
  NoteItem? _selectedNote;

  List<NoteItem> get notes => _notes;
  NoteItem? get selectedNote => _selectedNote;

  NoteProvider() {
    _loadNotes();
  }

  // 从Hive加载笔记
  void _loadNotes() {
    final noteMaps = _box.get('notes', defaultValue: []);
    if (noteMaps is List) {
      _notes.clear();
      for (final item in noteMaps) {
        if (item is Map) {
          _notes.add(NoteItem.fromMap(item));
        }
      }
      _sortNotes();
      notifyListeners();
    }
  }

  // 保存笔记到Hive
  void _saveNotes() {
    _box.put('notes', _notes.map((item) => item.toMap()).toList());
  }

  // 添加新笔记
  NoteItem addNote({String title = '新笔记', String content = ''}) {
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
    _saveNotes();
    notifyListeners();
    return newNote;
  }

  // 更新笔记内容
  void updateNote({
    required String id,
    String? title,
    String? content,
  }) {
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
      _saveNotes();
      notifyListeners();
    }
  }

  // 删除笔记
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);

    if (_selectedNote?.id == id) {
      _selectedNote = _notes.isNotEmpty ? _notes[0] : null;
    }

    _saveNotes();
    notifyListeners();
  }

  // 选择当前笔记
  void selectNote(String id) {
    final note = _notes.firstWhere(
      (note) => note.id == id,
      orElse: () => _notes.isNotEmpty ? _notes[0] : addNote(),
    );

    _selectedNote = note;
    notifyListeners();
  }

  // 按更新时间排序笔记
  void _sortNotes() {
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
