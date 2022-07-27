import 'package:calorie_check/meal_track/historyInfo.dart';
import 'package:calorie_check/user_preferences_track/user_info.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:intl/intl.dart';

class DatabaseHandlers {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'mydb.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE userPref(id INTEGER PRIMARY KEY AUTOINCREMENT, water INTEGER,  dateTime TEXT)",
        );
      },
      version: 1,
    );
  }

  // SQL code to create the database table

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insertUser(List<UserInfo> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var user in users) {
      result = await db.insert('userPref', user.toMap());
    }
    return result;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<UserInfo>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('userPref');
    return queryResult.map((e) => UserInfo.fromMap(e)).toList();
  }

  Future<List<HistoryInfo>> retrieveUsersDate(String date) async {
    //var curr = DateTime.now().day;
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(
      'userPref',
      where: 'dateTime=?',
      whereArgs: [date],
    );
    return queryResult.map((e) => HistoryInfo.fromMap(e)).toList();
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  // Future<int> queryRowCount() async {
  //   Database db = await instance.database;
  //   return Sqflite.firstIntValue(
  //       await db.rawQuery('SELECT COUNT(*) FROM $table'));
  // }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<void> deleteUser(int? id) async {
    final db = await initializeDB();
    await db.delete(
      'history',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updateUser(HistoryInfo historyInfo) async {
    final db = await initializeDB();
    await db.update(
      'history',
      historyInfo.toMap(),
      where: "id = ?",
      whereArgs: [historyInfo.id],
    );
  }

  Future<void> dateUser(int? date) async {
    final db = await initializeDB();
    await db.query(
      'history',
      where: "$date",
      whereArgs: [date],
    );
  }

  Future<int> deleteData(int id) async {
    final db = await initializeDB();
    return await db.rawDelete("DELETE FROM history WHERE id=$id");
  }

  Future glassWater(DateTime date) async {
    final db = await initializeDB();
    var newFormat = DateFormat("yy-MM-dd");
    String dt = newFormat.format(date);
    var result = await db.rawQuery(
        "SELECT water  from userPref where dateTime=? ORDER BY id DESC LIMIT 1 ",
        [dt]);
    print(result);
    return result.toList();
  }
}
