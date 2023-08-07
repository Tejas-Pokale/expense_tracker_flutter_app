import 'package:expense_tracker/models/expense.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  DatabaseHelper.internal();

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'my_expense.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Expenses(
        id TEXT PRIMARY KEY,
        title TEXT,
        amount DOUBLE,
        date TEXT,
        category TEXT
      )
    ''');
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    print('Expense inserted');
    return await db!.insert('Expenses', expense.toMap());
  }

  Future<int> removeExpense(Expense expense) async {
    final db = await database;
    print('Expense deleted');
    return await db!
        .delete('Expenses', where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('Expenses', orderBy: 'date DESC');
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<void> close() async {
    final db = await database;
    db!.close();
  }
}
