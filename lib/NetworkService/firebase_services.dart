import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sales_task_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shopName TEXT NOT NULL,
        productSold TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  // Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Get task count
  Future<int> getTaskCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get pending sync count
  Future<int> getPendingSyncCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE synced = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Mark tasks as synced
  Future<int> markTaskAsSynced(int id) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sync tasks to server (mock implementation)
  Future<void> syncTasks() async {
    // In a real app, this would send data to a server
    // This is just a mock implementation
    final db = await database;
    final unsynced = await db.query(
      'tasks',
      where: 'synced = ?',
      whereArgs: [0],
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mark all as synced
    if (unsynced.isNotEmpty) {
      await db.update(
        'tasks',
        {'synced': 1},
        where: 'synced = ?',
        whereArgs: [0],
      );
    }
  }
}