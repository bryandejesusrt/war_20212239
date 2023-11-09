import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';
import 'package:war_20212239/modal_class/notes.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String noteTable = 'notes';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colColor = 'color';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database?> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<Database?> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'vivencias.db');
    print('Database path: $path');

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    print('Database opened successfully');
    return notesDatabase;
  }

  void onCreate(Database db, int version) async {
    // Insertar un registro de manera manual
    await insertNote(Note('Nueva vivencia', 'Este es un registro nuevo', 3, 0));
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colColor INTEGER, $colDate TEXT)');
  }

  // Fetch Operation: Get all note objects from the database
  Future<List<Map<String, dynamic>>?> getNoteMapList() async {
    Database? db = await database;
    var result = await db?.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation: Insert a Note object into the database
  Future<int?> insertNote(Note note) async {
    Database? db = await database;
    var result = await db?.insert('notes', note.toMap());
    print('Insert result: $result');
    return result ?? 0;
  }

  Future<int> updateNote(Note note) async {
    var db = await database;
    var result = await db?.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result ?? 0;
  }

  Future<int> deleteNote(int id) async {
    var db = await database;
    int result =
        await db?.delete(noteTable, where: '$colId = ?', whereArgs: [id]) ?? 0;
    return result;
  }

  // Get the number of Note objects in the database
  Future<int?> getCount() async {
    Database? db = await database;
    int? result = Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $noteTable'));
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to a 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList!.length;
    List<Note> noteList = [];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future<int> deleteAllNotes() async {
    var db = await database;
    int? result = await db?.rawDelete('DELETE FROM $noteTable');
    return result ?? 0;
  }
}
