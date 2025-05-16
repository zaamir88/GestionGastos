import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/gasto.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'gastos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT,
        categoria TEXT,
        monto REAL,
        fecha TEXT
      )
    ''');
  }

  static Future<int> insertGasto(Gasto gasto) async {
    final db = await database;
    return await db.insert('gastos', gasto.toMap());
  }

  static Future<List<Gasto>> getGastos() async {
    final db = await database;
    final res = await db.query('gastos');
    return res.map((e) => Gasto.fromMap(e)).toList();
  }

  static Future<int> updateGasto(Gasto gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  static Future<int> deleteGasto(int id) async {
    final db = await database;
    return await db.delete(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
