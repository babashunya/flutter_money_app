import 'dart:io';
import 'package:flutter_money_app/models/money.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'MoneyData.db';
  static const _databaseVersion = 1;

// Singleton class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    print(dbPath);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Money.tblMoney} (
        ${Money.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Money.colCategoryId} INTEGER NOT NULL,
        ${Money.colAmount} INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMoney(Money money) async {
    Database db = await database;
    print(money.toMap());
    return await db.insert(Money.tblMoney, money.toMap());
  }

  Future<int> updateMoney(Money money) async {
    Database db = await database;
    print(money.toMap());
    return await db.update(Money.tblMoney, money.toMap(),
        where: '${Money.colId}=?', whereArgs: [money.id]);
  }

  Future<int> deleteMoney(int id) async {
    Database db = await database;
    return await db
        .delete(Money.tblMoney, where: '${Money.colId}=?', whereArgs: [id]);
  }

  Future<List<Money>> fetchMoneys() async {
    Database db = await database;
    List<Map> moneys = await db.query(Money.tblMoney);
    return moneys.length == 0
        ? []
        : moneys.map((e) => Money.fromMap(e)).toList();
  }
}
