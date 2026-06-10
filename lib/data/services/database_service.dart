import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/feedback_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'feedback_collector.db');

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE feedbacks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deviceOwner TEXT NOT NULL,
        userName TEXT NOT NULL,
        userEmail TEXT NOT NULL,
        userContact TEXT NOT NULL,
        bugDescription TEXT NOT NULL,
        userDevice TEXT NOT NULL,
        mediaPaths TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertFeedback(FeedbackModel feedback) async {
    final db = await database;
    return await db.insert(
      'feedbacks',
      feedback.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    final db = await database;
    final maps = await db.query('feedbacks', orderBy: 'createdAt DESC');
    return maps.map((map) => FeedbackModel.fromMap(map)).toList();
  }

  Future<int> deleteFeedback(int id) async {
    final db = await database;
    return await db.delete('feedbacks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
