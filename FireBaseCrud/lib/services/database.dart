import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class Employee {
  int? id;
  String firstName;
  String lastName;
  String address;

  Employee({this.id, required this.firstName, required this.lastName, required this.address});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'employee_database.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT, lastName TEXT, address TEXT)',
      );
    });
  }

  Future<void> insertEmployee(Employee employee) async {
    final db = await database;
    await db.insert('employees', employee.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEmployee(Employee employee) async {
    final db = await database;
    await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<void> deleteEmployee(int id) async {
    final db = await database;
    await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  Future<List<Employee>> searchEmployees(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'firstName LIKE ? OR lastName LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }
}
