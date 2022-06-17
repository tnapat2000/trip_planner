import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:async';


import 'package:path_provider/path_provider.dart';
import 'day_class.dart';

class SQLDB {

  SQLDB._();
  static final SQLDB instance = SQLDB._();

  static Database? _database;
  Future<Database> get db async => _database ??= await _db();

  Future _createTables(Database database, int version) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS plans(
        day INTEGER NOT NULL,
        loc_id INTEGER,
        loc_name TEXT,
        arrive_time INTEGER,
        exit_time INTEGER,
        completed INTEGER,
        PRIMARY KEY (day, loc_id)
      );
      """);
  }

  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);

  Future<Database> _db() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'plan_db.db');
    // deleteDatabase(path);
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future emptyTable() async {
    final db = await instance.db;
    await db.rawQuery("DELETE FROM plans");
  }

  Future<void> insertDay(Day day) async {
    final db = await instance.db;
    await db.insert('plans', day.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Day>> allDays() async {
    final db = await instance.db;
    List<Map<String, dynamic>> maps = await db.query('plans');

    return List.generate(maps.length, (index) {
      // print([maps[index]['day_id'] , maps[index]['loc_id'] ]);
      return Day(
          day: maps[index]['day'],
          locId: maps[index]['loc_id'],
          locName: maps[index]['loc_name'],
          arriveTime: maps[index]['arrive_time'],
          exitTime: maps[index]['exit_time'],
          completed: maps[index]["completed"]);
    });
  }

  Future<List<Day>> allSpecificDay(int day) async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM plans WHERE day=?', [day]);

    return List.generate(maps.length, (index) {
      // print([maps[index]['day_id'] , maps[index]['loc_id'] ]);
      return Day(
          day: maps[index]['day'],
          locId: maps[index]['loc_id'],
          locName: maps[index]['loc_name'],
          arriveTime: maps[index]['arrive_time'],
          exitTime: maps[index]['exit_time'],
          completed: maps[index]["completed"]);
    });
  }

  Future<void> updateDay(Day day) async {
    final db = await instance.db;
    await db.update('plans', day.toMap(),
        whereArgs: [day.day, day.locId], where: 'day = ? and loc_id = ?');
  }

  Future<void> deleteDay(int id) async {
    final db = await instance.db;
    await db.delete('plans', whereArgs: [id], where: 'day = ?');
  }

  Future<List<int>> getAllLocIds(int day) async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps =
    await db.rawQuery('SELECT loc_id FROM plans WHERE day=?', [day]);

    return List.generate(maps.length, (index) {
      // print([maps[index]['day_id'] , maps[index]['loc_id'] ]);
      return maps[index]['loc_id'];
    });
  }

  Future<List<int>> getAllDayNum() async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps =
    await db.rawQuery('SELECT DISTINCT day FROM plans');

    return List.generate(maps.length, (index) {
      // print([maps[index]['day_id'] , maps[index]['loc_id'] ]);
      return maps[index]['day'];
    });
  }

  Future<void> deleteLoc(int id) async {
    final db = await instance.db;
    await db.delete('plans', whereArgs: [id], where: 'loc_id = ?');
  }

}
