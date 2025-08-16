// db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 3, // increment kapag may bagong table
      onCreate: (db, version) async {
        // User Table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullname TEXT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');

        // Guest Table
        await db.execute('''
          CREATE TABLE guest (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            guest_name TEXT,
            vehicle_plate TEXT,
            expected_arrival TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN fullname TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS guest (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              guest_name TEXT,
              vehicle_plate TEXT,
              expected_arrival TEXT
            )
          ''');
        }
      },
    );
  }

  // 🔹 Register User
  Future<int> registerUser(
    String fullname,
    String username,
    String password,
  ) async {
    final db = await database;
    return await db.insert("users", {
      "fullname": fullname,
      "username": username,
      "password": password,
    });
  }

  // 🔹 Login User
  Future<Map<String, dynamic>?> loginUser(
    String username,
    String password,
  ) async {
    final db = await database;
    final res = await db.query(
      "users",
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // 🔹 Register Guest
  Future<int> registerGuest(
    String guestName,
    String vehiclePlate,
    String expectedArrival,
  ) async {
    final db = await database;
    return await db.insert("guest", {
      "guest_name": guestName,
      "vehicle_plate": vehiclePlate,
      "expected_arrival": expectedArrival,
    });
  }

  // 🔹 Get all Guests
  Future<List<Map<String, dynamic>>> getGuests() async {
    final db = await database;
    return await db.query("guest", orderBy: "id DESC");
  }
}
