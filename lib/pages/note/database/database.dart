import 'package:fumeo/pages/note/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 数据库服务类
class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // 创建数据库表
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createTime TEXT NOT NULL,
        wordCount INTEGER NOT NULL
      )
    ''');
  }

  // 创建笔记
  Future<Note> create(Note note) async {
    final db = await instance.database;
    await db.insert('notes', note.toJson());
    return note;
  }

  // 读取单个笔记
  Future<Note?> readNote(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      columns: ['id', 'title', 'content', 'createTime', 'wordCount'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    }
    return null;
  }

  // 读取所有笔记
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'createTime DESC');
    return result.map((json) => Note.fromJson(json)).toList();
  }

  // 更新笔记
  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // 删除笔记
  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 搜索笔记
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createTime DESC',
    );
    return result.map((json) => Note.fromJson(json)).toList();
  }

  // 关闭数据库
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
