import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class ProductModel {
  int? id;
  String materialName;
  String stockCode;
  int quantity;

  ProductModel({this.id, required this.materialName, required this.stockCode, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialName': materialName,
      'stockCode': stockCode,
      'quantity': quantity,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      materialName: map['materialName'],
      stockCode: map['stockCode'],
      quantity: map['quantity'],
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
    final path = join(await getDatabasesPath(), 'product_database.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, materialName TEXT, stockCode TEXT, quantity INTEGER)'
      );
    });
  }

  Future<void> insertProduct(ProductModel product) async {
    final db = await database;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProduct(ProductModel product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getProductCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'materialName LIKE ? OR stockCode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }
}
