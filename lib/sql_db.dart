import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:async';


import 'package:path_provider/path_provider.dart';
import 'day_class.dart';

class SQLDB {

  // initiate database
  SQLDB._();
  static final SQLDB instance = SQLDB._();

  // singleton
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

  // in case of database malfunction
  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);

  Future<Database> _db() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'plan_db.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  // clear table
  Future emptyTable() async {
    final db = await instance.db;
    await db.rawQuery("DELETE FROM plans");
  }

  // insert new day
  Future<void> insertDay(Day day) async {
    final db = await instance.db;
    await db.insert('plans', day.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // get all days in the database
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

  // get all location from a specific day
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

  // return only location ids within a day
  Future<List<int>> getAllLocIds(int day) async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps =
    await db.rawQuery('SELECT loc_id FROM plans WHERE day=?', [day]);

    return List.generate(maps.length, (index) {
      return maps[index]['loc_id'];
    });
  }

  // return only unique day numbers
  Future<List<int>> getAllDayNum() async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps =
    await db.rawQuery('SELECT DISTINCT day FROM plans');

    return List.generate(maps.length, (index) {
      return maps[index]['day'];
    });
  }

  // delete location
  Future<void> deleteLoc(int id) async {
    final db = await instance.db;
    await db.delete('plans', whereArgs: [id], where: 'loc_id = ?');
  }

}
