import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sticky_notes_app/Widgets/CustomWidgets.dart';

class Notesaddscreen extends StatefulWidget {
  final int colorIndex; // Accept colorIndex as a parameter

  const Notesaddscreen({Key? key, required this.colorIndex}) : super(key: key);

  @override
  State<Notesaddscreen> createState() => _NotesaddscreenState();
}

class _NotesaddscreenState extends State<Notesaddscreen> {
  final TitleController = TextEditingController(); // Correct variable name
  final DescriptionController = TextEditingController(); // Correct variable name

  final List<Color> noteColors = [
    Colors.red.shade300,
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.yellow.shade300,
    Colors.orange.shade300
  ]; // Predefined color list

  late int colorIndex; // Local colorIndex for the current note

  @override
  void initState() {
    super.initState();
    colorIndex = widget.colorIndex; // Initialize with the passed colorIndex
  }

  Future<void> _addNote() async {
  try {
    // Get the current user
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Get the user's email
      final String email = currentUser.email!;

      // Get the current color and increment the index for the next note
      final color = noteColors[colorIndex % noteColors.length].value; // Save color as int

      // Add note with color to Firestore under the collection named after the user's email
      await FirebaseFirestore.instance.collection(email).add({
        'title': TitleController.text,
        'description': DescriptionController.text,
        'color': color, // Save the color value
        'timestamp': FieldValue.serverTimestamp(), // To order by creation time
      });

      Navigator.pop(context); // Go back to the HomeScreen after adding the note
    } else {
      print('No user is logged in.');
    }
  } catch (e) {
    print('Error adding note: $e');
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
              await _addNote(); // Add note on save tap
            },
            child: Text('Save'),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: ListView(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text('Title',
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.green)),
            ),
            CustomWidgets().CustomTextField(TitleController, 3,),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.topLeft,
              child: Text('Description',
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.green)),
            ),
            CustomWidgets().CustomTextField(DescriptionController, 18),
          ],
        ),
      ),
    );
  }
}
