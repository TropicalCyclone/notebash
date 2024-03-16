import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class NotesDatabase {
  static Database? _database;
  static const String dbName = 'notes.db';
  static const String notesTable = 'notes';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }
    // This class manages the SQLite database for notes within the application.

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $notesTable(id INTEGER PRIMARY KEY, userId INTEGER, title TEXT, description TEXT, dateCreated TEXT)",
        );
      },
      version: 1,
    );
  }
// This initDatabase() function initializes the SQLite database by creating a table
// named notes with columns for id, userId, title, description, and dateCreated,
// using the openDatabase function provided by the sqflite package.

  Future<void> insertNote(Note note) async {
    final Database db = await database;
    await db.insert(
      notesTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
// This insertNote method inserts a new note into the database by converting it
// into a map using note.toMap() and inserting it into the notesTable, utilizing
// the ConflictAlgorithm.replace strategy to handle conflicts.

  Future<List<Note>> getNotesByUserId(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        userId: maps[i]['userId'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        dateCreated: DateTime.parse(maps[i]['dateCreated']),
      );
    });
  }
//This getNotesByUserId method retrieves a list of notes associated with a specific
// userId from the database, by querying the notesTable where the userId matches the
// provided value, and then generating a list of Note objects from the retrieved data,
// converting dateCreated from string to DateTime format.

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
// The updateNote method updates an existing note in the database by converting it
// into a map representation, and subsequently utilizing the db.update function to
// update the corresponding row in the notesTable where the id matches the note.id.

  Future<void> deleteNote(Note note) async {
    final db = await database;
    await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
//The deleteNote method removes a note from the database by utilizing the db.delete
// function to delete the row in the notesTable where the id matches the note.id.The
// deleteNote method removes a note from the database by utilizing the db.delete function
// to delete the row in the notesTable where the id matches the note.id.

  Future<void> importNotes(String jsonContent) async {
    List<dynamic> decodedList = json.decode(jsonContent);
    for (var item in decodedList) {
      Note note = Note(
        userId: item['userId'],
        title: item['title'],
        description: item['description'],
        dateCreated: DateTime.parse(item['dateCreated']),
      );
      await insertNote(note);
    }
  }
//The importNotes method parses a JSON string containing note data, iterates over
// each item, constructs a Note object, and inserts it into the database using the insertNote method.

  Future<String> exportNotes(int userId) async {
    final List<Note> notes = await getNotesByUserId(userId);
    List<Map<String, dynamic>> exportList = notes.map((note) => note.toMap()).toList();

    // Get the directory for storing exported files (documents directory)
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

    String filePath = '${appDocumentsDirectory.path}/notes_export.json';
    File exportFile = File(filePath);
    await exportFile.writeAsString(json.encode(exportList));
    return filePath;
  }
//The exportNotes method retrieves notes associated with a specific user ID from
// the database, converts them into a list of maps, writes the data to a JSON file
// in the device's documents directory, and returns the file path.

  Future<String> exportSingleNote(int noteId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'id = ?',
      whereArgs: [noteId],
    );
    if (maps.isNotEmpty) {
      Note note = Note(
        id: maps[0]['id'],
        userId: maps[0]['userId'],
        title: maps[0]['title'],
        description: maps[0]['description'],
        dateCreated: DateTime.parse(maps[0]['dateCreated']),
      );
      return json.encode(note.toMap());
    } else {
      throw Exception('Note not found');
    }
  }
}
//The exportSingleNote method retrieves a single note by its ID from the database,
// constructs a Note object from the retrieved data, encodes it into a JSON string,
// and returns it, or throws an exception if the note is not found.

class Note {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final DateTime dateCreated;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateCreated,
  });
// The Note class defines a model representing a note with properties including
// an optional ID, user ID, title, description, and date created.

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }
}
//The toMap method converts the Note object into a map of key-value pairs where
// the keys represent the properties of the note (userId, title, description, dateCreated),
// and the values represent their respective values. The dateCreated is converted to
// a string in ISO 8601 format before being added to the map.