import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'User.dart';

class NoteBashAccountDatabase {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'notebash_accounts.db'),
      onCreate: _createDB,
      version: 1,
    );
  }
//  this method sets up the database for the application.It retrieves the path to
//  store the database file, then opens or creates the database file with a specified name and version

  Future<void> _createDB(Database database, int version) async {
    await database.execute(
      "CREATE TABLE accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT);",
    );
    //await database.execute(
    //  "INSERT INTO accounts(username, password) VALUES ('user', 'password')",
    //);
  }
  //This method sets up the initial schema of the accounts table in the database.
  // It defines the structure of the table with columns for storing usernames and passwords.
  // this method sets up the initial schema of the accounts table in the database.
  // It defines the structure of the table with columns for storing usernames and passwords.

  Future<int> insertAccount(User user) async {
    final db = await initializeDB();
    int result = await db.insert(
      'accounts',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }
// this method inserts a new user account into the database
// and returns the result, indicating the success or failure of the insertion operation.

  Future<bool> checkLogin(String username, String password) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return accounts.isNotEmpty;
  }
// checks if a user with the provided username and password exists in the database
// and returns a boolean indicating the result of the login attempt.

  Future<int> getUserId(String username) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );
    if (accounts.isNotEmpty) {
      return accounts.first['id'];
    } else {
      return -1;
    }
  }
// this method retrieves the user ID associated with a given username from the
//database and returns it as an integer. If no matching user is found, it returns -1.

  Future<bool> isUsernameTaken(String username) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'username = ?',
      whereArgs: [username],
    );
    return accounts.isNotEmpty;
  }
}
//this method checks if a given username already exists in the database and returns
// a boolean indicating whether it's taken or not.