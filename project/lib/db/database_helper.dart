// ignore_for_file: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'paypay_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        amount INTEGER
      )
    ''');
  }

  Future<int> insertPayment(Map<String, dynamic> payment) async {
    Database db = await instance.database;
    return await db.insert('payments', payment);
  }

  Future<List<Map<String, dynamic>>> getAllPayments() async {
    Database db = await instance.database;
    return await db.query('payments', orderBy: 'timestamp DESC');
  }

  Future<int> getWeeklyDonationTotal(context) async {
    final db = await openDatabase("payments");

    final currentDate = DateTime.now();
    final monday =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final total = Sqflite.firstIntValue(await db.rawQuery('''
    SELECT SUM(amount) FROM amount
    WHERE timestamp BETWEEN ? AND ?
  ''', [monday.toIso8601String(), sunday.toIso8601String()]));

    return total ?? 0;
  }

  Future<String> getLastPaymentTimestamp() async {
    Database db = await instance.database;
    String timestamp = '';

    List<Map<String, dynamic>> result = await db.query(
      'payments',
      orderBy: 'timestamp DESC', // 降順にソート
      limit: 1, // 最初の1行のみを取得
    );

    if (result.isNotEmpty) {
      // 最後の支払いのタイムスタンプを取得
      timestamp = result.first['timestamp'];
    }
    // データベースに支払い情報がない場合
    return timestamp;
  }
}

class DatabaseInformation {
  static final DatabaseInformation instance =
      DatabaseInformation._privateConstructor();
  static Database? _database;

  DatabaseInformation._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'info_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE information (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        frequency TEXT,
        setamount INTEGER
      )
    ''');
  }

  Future<Map<String, dynamic>?> getLastInformation() async {
    final db = await database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      'SELECT * FROM information ORDER BY id DESC LIMIT 1',
    );

    if (rows.isNotEmpty) {
      return rows.first;
    }

    return null;
  }

  Future<int> insertInfo(Map<String, dynamic> infoData) async {
    final db = await database;
    return await db.insert('information', infoData);
  }
}
