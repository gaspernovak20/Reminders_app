import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

//datoteka kjer se urejajo informacije za shranjevanje podatkov na napravo

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    //pridobimo pot kjer shranimo podatke
    return sql.openDatabase(
      path.join(dbPath, 'reminders.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE USER_REMINDERS(id TEXT PRIMARY KEY, title TEXT, notes TEXT, url TEXT, isFlaged INTEGER, isCompleted INTEGER, notifyTime TEXT, isNotifyDays INTEGER, isNotifyHours INTEGER)',
        );
        //ustvarimo tabelo in določimo imena spremenlivk ki jih bomo shranjevali
      },
      version: 1,
    );
  }

  //funkcija ki nam omogoča shranjevanje podatkov na napravos
  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    //se povežemo z bazo
    await db.insert(
      table,
      data,
      //vnesemo ime table in vse podatke
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  //funkcija s katero pridobimo podatke iz naprave
  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
    //samo vneseomo ime tabele
  }

  //funkcija s katero obnovimo podatke iz naprave
  static Future<void> update(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.update(
      table,
      data,
      //vnesemo ime tabele in podatke
      where: 'id=?',
      whereArgs: [data['id']],
      //obnovi se samo za določen reminder
    );
  }

  //funkcija s katero izbriđemo podatke iz naprave
  static Future<void> delete(String table, String id) async {
    final db = await DBHelper.database();
    db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
      //izberemo tabelo in id opomnika
    );
  }

  //funkcija s spremeni vrednost booliana (da ali ne vrednost)
  static Future<void> boolUpdate(
      String table, String name, String id, int value) async {
    final db = await DBHelper.database();
    db.rawUpdate('''UPDATE $table SET $name = ? WHERE id = ?''', [value, id]);
  }
}
