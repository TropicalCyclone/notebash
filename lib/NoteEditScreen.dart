import 'package:flutter/material.dart';
import 'package:notebash_app/NotesDatabase.dart';

class NoteEditScreen extends StatefulWidget {
  final int userId;
  final Note? note;
  final bool isUpdating;

  NoteEditScreen({required this.userId, this.note, required this.isUpdating});

//  this class serves as a configurable screen for editing or creating notes within
//  an application, with flexibility to handle both new note creation and existing note updates.

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
  }
//  this code segment sets up the state for the NoteEditScreen widget by initializing
//  text editing controllers for the title and description fields with either the
//  existing note's data (if available) or empty strings.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          title: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter title',
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
            ),
          ),
          actions: [
            if (widget.isUpdating)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
              ),
          ],
        ),
      ),
      //  this build method constructs an app bar for the note editing screen with
      //  a text field for the note title and an optional delete button if the screen is for updating an existing note.

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.0),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter Note',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
          ],
        ),
      ),
      // this code segment creates a scrollable text input field for entering the
      // note's description, ensuring that the UI is responsive and user-friendly for editing longer notes.

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.isUpdating) {
            _updateNote();
          } else {
            _saveNote();
          }
        },
        child: Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
    // This code segment adds a floating action button to the NoteEditScreen widget,
    // which allows users to either save a new note or update an existing one, depending on the context of the screen.

  void _saveNote() {
    // Save note
    final newNote = Note(
      userId: widget.userId,
      title: _titleController.text,
      description: _descriptionController.text,
      dateCreated: DateTime.now(),
    );
    NotesDatabase().insertNote(newNote);
    Navigator.pop(context);
  }
    // This _saveNote() function creates a new Note object with data from text controllers,
    // inserts it into the database, and then pops the current screen from the navigation stack to
    // return to the previous screen.

  void _updateNote() {
    if (widget.note != null) {
      //print("updated note");
      final updatedNote = Note(
        id: widget.note!.id,
        userId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        dateCreated: DateTime.now(),
      );
      NotesDatabase().updateNote(updatedNote);
      Navigator.pop(context);
    }
  }
    // This function updates an existing note with data from text controllers, then
    // updates it in the database, and pops the current screen from the navigation stack
    // to return to the previous screen.

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteNoteAndNavigateBack();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
    // This _showDeleteConfirmationDialog function displays an AlertDialog with a title
    // asking for confirmation to delete a note, providing options to either cancel the
    // action or proceed with deletion. Upon pressing the "Delete" button, it calls _deleteNoteAndNavigateBack()
    // to delete the note and navigate back to the previous screen.

  void _deleteNoteAndNavigateBack() async {
    if (widget.note != null) {
      await NotesDatabase().deleteNote(widget.note!);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}
    //This _deleteNoteAndNavigateBack() function deletes an existing note from the database,
    // then pops the current screen from the navigation stack twice to return to the screen
    // that precedes the editing screen.