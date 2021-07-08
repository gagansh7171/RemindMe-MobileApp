import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tableReminders = 'reminders';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnDate = 'date';
final String columnDesc = 'desc';
final String columnToggle = 'toggle';

// data model class
class Reminder {
  int? id;
  final String title;
  final DateTime date;
  final String desc;
  bool toggle;
  Reminder({
    required this.title,
    required this.desc,
    required this.toggle,
    required this.date,
  });
  Reminder.fromMap(Map<dynamic, dynamic> map)
      : title = map[columnTitle],
        desc = map[columnDesc],
        toggle = map[columnToggle] == 1 ? true : false,
        id = map[columnId],
        date = DateTime.parse(map[columnDate]);

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date.toString(),
        'desc': desc,
        'toggle': toggle ? 1 : 0
      };
}

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "MyDatabase.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableReminders (
                $columnId INTEGER PRIMARY KEY,
                $columnTitle TEXT NOT NULL,
                $columnDate TEXT NOT NULL,
                $columnDesc TEXT NOT NULL,
                $columnToggle INTEGER NOT NULL
              )
              ''');
  }

  Future<int?> insert(Reminder reminder) async {
    Database? db = await database;
    int? id = await db?.insert(tableReminders, reminder.toMap());
    return id;
  }

  Future update(Reminder reminder, int id) async {
    Database? db = await database;
    int? count = await db?.rawUpdate(
        'UPDATE $tableReminders SET $columnTitle = ?, $columnDate = ?, $columnDesc = ?, $columnToggle = ? WHERE $columnId = ?',
        [
          reminder.title,
          reminder.date.toString(),
          reminder.desc,
          reminder.toggle,
          id
        ]);
    print(count);
  }

  Future delete(int id) async {
    Database? db = await database;
    int? count = await db
        ?.rawDelete('DELETE from $tableReminders WHERE $columnId = ?', [id]);
  }

  Future<List<Reminder>?> queryReminder() async {
    Database? db = await database;
    List<Map>? maps = await db?.rawQuery('SELECT * FROM $tableReminders');
    if (maps!.length > 0) {
      return maps.map((e) => Reminder.fromMap(e)).toList();
    }
    return [];
  }

  void close() async => _database?.close();
}
