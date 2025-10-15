import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/employee_model.dart';

class DatabaseHelper {
  static const _databaseName = "hr_database.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

Future<Database> _initDatabase() async {
  // Pastikan path database valid dan foldernya ada
  final dbPath = await databaseFactoryFfi.getDatabasesPath();

  // Buat folder database jika belum ada
  final directory = Directory(dbPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final path = join(dbPath, _databaseName);
  // Buka atau buat database baru
  return await databaseFactoryFfi.openDatabase(path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
      ));
}

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        idCard TEXT,
        name TEXT,
        phone TEXT,
        birthPlace TEXT,
        birthDate TEXT,
        addressKTP TEXT,
        addressNow TEXT,
        ktaNumber TEXT,
        ktaExpired TEXT,
        joinDate TEXT,
        placement TEXT,
        status TEXT,
        bpjsHealth TEXT,
        bpjsTK TEXT,
        salaryBasic REAL,
        allowanceHouse REAL,
        allowanceMeal REAL,
        allowanceTransport REAL,
        allowancePosition REAL,
        deductionBPJSHealth REAL,
        deductionBPJSTK REAL,
        takeHomePay REAL,
        photoPath TEXT
      )
    ''');
  }

  // CRUD Functions
  Future<int> insertEmployee(EmployeeModel employee) async {
    Database db = await instance.database;
    return await db.insert('employees', employee.toMap());
  }

  Future<List<EmployeeModel>> getAllEmployees() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) => EmployeeModel.fromMap(maps[i]));
  }

  Future<int> updateEmployee(EmployeeModel employee) async {
    Database db = await instance.database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(String id) async {
    Database db = await instance.database;
    return await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }
}
