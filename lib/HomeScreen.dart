import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/LoginPage.dart';
import 'package:notebash_app/NotesDatabase.dart';
import 'package:notebash_app/NoteEditScreen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Note> notes;
  final dbHelper = NotesDatabase();
  String? _selectedDirectoryPath;

  @override
  void initState() {
    super.initState();
    notes = [];
    refreshNotes();
  }
  //In the initState method, the widget initializes an empty list for notes and
  // then calls the refreshNotes function to fetch the notes from the database
  // and update the UI accordingly.

  void refreshNotes() async {
    List<Note> _notes = await dbHelper.getNotesByUserId(widget.userId);
    setState(() {
      notes = _notes;
    });
  }
//The refreshNotes function retrieves the notes associated with the current user
// from the database and updates the state to reflect the changes, ensuring that
// the UI displays the latest notes.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NoteBash'),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.menu),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.folder_open),
                    title: Text('Select Export Folder'),
                    onTap: _selectDestinationFolder,
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.import_export),
                    title: Text('Export Database'),
                    onTap: () {
                      if (_selectedDirectoryPath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select a destination folder first.'),
                          ),
                        );
                      } else {
                        _exportDatabase();
                      }
                    },
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      //This code sets up an app bar with a title "NoteBash" and a menu button.
      // When the menu button is tapped, a popup menu appears with options to select
      // an export folder, export the database, and logout. Each option triggers a
      // corresponding action when tapped, such as selecting a destination folder,
      // exporting the database, or navigating to the login page.

      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditScreen(userId: widget.userId, note: notes[index], isUpdating: true),
                ),
              ).then((value) => refreshNotes());
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(notes[index].title),
                subtitle: Text('${notes[index].dateCreated.toString()}'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showOptions(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
//This code displays a list of notes, where each note is represented as a card
// with its title and creation date. It also provides a floating action button to
// show options for adding new notes or importing existing ones.

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                ListTile(
                  leading: new Icon(Icons.note),
                  title: new Text('Create New Note'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditScreen(userId: widget.userId, isUpdating: false,),
                      ),
                    ).then((value) => refreshNotes());
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.import_export),
                  title: new Text('Import Note'),
                  onTap: () {
                    Navigator.pop(context);
                    _importNote();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
//The _showOptions function displays a modal bottom sheet with options to either
// create a new note or import a note, and upon selection, it either navigates to
// the note editing screen or triggers the import process while ensuring to refresh
// notes afterward.

  void _importNote() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String contents = await file.readAsString();
      await dbHelper.importNotes(contents);
      refreshNotes();
    }
  }
//The _importNote function prompts the user to select a JSON file, reads its contents,
// imports the notes from the file using the importNotes method, and refreshes the notes
// displayed on the screen.

  void _selectDestinationFolder() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _selectedDirectoryPath = directoryPath;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Destination folder selected: $directoryPath'),
        ),
      );
    }
  }
  // The _selectDestinationFolder function utilizes the FilePicker plugin to prompt
  // the user to select a destination folder for exporting files. If a folder is
  // selected, it updates the _selectedDirectoryPath state variable and displays a
  // snackbar indicating the selected destination folder.

  void _exportDatabase() async {
    if (_selectedDirectoryPath != null) {
      String filePath = await dbHelper.exportNotes(widget.userId);
      File exportFile = File(filePath);
      if (exportFile.existsSync()) {
        // Generate unique file name using current date and time
        DateTime now = DateTime.now();
        String formattedDate = '${now.minute}_${now.hour}_${now.day}_${now.month}_${now.year}';
        String newFileName = 'notes_export_$formattedDate.json';

        // Construct the new file path
        String newFilePath = path.join(_selectedDirectoryPath!, newFileName);

        // Copy the file to the chosen directory with the new file name
        await exportFile.copy(newFilePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported successfully to $newFilePath'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting file.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a destination folder first.'),
        ),
      );
    }
  }
  // This _exportDatabase function exports notes from the database to a JSON file,
// copies it to a chosen directory with a unique file name based on the current date
// and time, and displays a snackbar with a success message if the export is successful,
// or an error message otherwise. If no destination folder is selected, it shows a snackbar
// prompting the user to select a destination folder.
}


