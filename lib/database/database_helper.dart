import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart' as mymodel;

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  static const _defaultCategory = 'Khác';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'money_tracker.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        type TEXT,
        category TEXT NOT NULL DEFAULT '$_defaultCategory'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final hasCategory = await _hasColumn(db, 'transactions', 'category');

      if (!hasCategory) {
        await db.execute(
          "ALTER TABLE transactions ADD COLUMN category TEXT DEFAULT '$_defaultCategory'",
        );
      }

      await db.rawUpdate(
        "UPDATE transactions SET category = ? WHERE category IS NULL OR TRIM(category) = ''",
        [_defaultCategory],
      );
    }
  }

  Future<bool> _hasColumn(
      Database db, String tableName, String columnName) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    return columns.any((column) => column['name'] == columnName);
  }

  Future<int> insertTransaction(mymodel.Transaction transaction) async {
    final db = await database;
    return db.insert('transactions', transaction.toMap());
  }

  Future<List<mymodel.Transaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');

    return List.generate(
      maps.length,
      (index) => mymodel.Transaction.fromMap(maps[index]),
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
