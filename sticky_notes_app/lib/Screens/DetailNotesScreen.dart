import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sticky_notes_app/Widgets/CustomWidgets.dart'; // For Firestore operations

class Detailnotesscreen extends StatefulWidget {
  final String noteId; // Use Firestore's auto-generated document ID
  final String title;
  final String description;

  Detailnotesscreen({
    required this.noteId,
    required this.title,
    required this.description,
  });

  @override
  State<Detailnotesscreen> createState() => _DetailnotesscreenState();
}

class _DetailnotesscreenState extends State<Detailnotesscreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title; // Initialize controllers with existing values
    _descriptionController.text = widget.description;
  }

  // Function to update the note in Firestore
  Future<void> _updateNote() async {
    try {
      // Get the current authenticated user
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Get the user's email
        final String email = currentUser.email!;

        // Update the note in the user's collection
        await FirebaseFirestore.instance
            .collection(email) // Use user's email as collection name
            .doc(widget.noteId) // Use the document ID for updating the note
            .update({
          'title': _titleController.text,
          'description': _descriptionController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note updated successfully')));
        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not authenticated.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating note: $e')));
    }
  }

  // Function to delete the note from Firestore
  Future<void> _deleteNote() async {
    try {
      // Get the current authenticated user
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Get the user's email
        final String email = currentUser.email!;

        // Delete the note from the user's collection
        await FirebaseFirestore.instance
            .collection(email) // Use user's email as collection name
            .doc(widget.noteId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note deleted successfully')));
        Navigator.pop(context); // Return to the previous screen after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not authenticated.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () async {
              await _updateNote(); // Call update function to save changes
            },
            child: Text("Update"),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        children: [
          SizedBox(height: 10.h),
          Text(
            "Change Title",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400, color: Colors.blue.shade400),
          ),
          SizedBox(height: 10.h),
          CustomWidgets().CustomTextField(_titleController, 3),
          SizedBox(height: 20.h),
          Text(
            "Change Description",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400, color: Colors.blue.shade400),
          ),
          SizedBox(height: 10.h),
          CustomWidgets().CustomTextField(_descriptionController, 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
         await _deleteNote(); // Call delete function to delete note
        },
        child: Icon(Icons.delete),
        ),
    );
  }
}
