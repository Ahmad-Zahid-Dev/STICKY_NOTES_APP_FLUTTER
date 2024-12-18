import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sticky_notes_app/Screens/DetailNotesScreen.dart';
import 'package:sticky_notes_app/Screens/LogInScreen.dart';
import 'package:sticky_notes_app/Screens/NotesAddScreen.dart';


class Homescreen extends StatefulWidget {
  final String title;

  Homescreen({this.title = ''});

  @override
  State<Homescreen> createState() {
    return _HomescreenState();
  }
}

class _HomescreenState extends State<Homescreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> searchedNotes = [];
  String searchText = ''; // Search query text
  bool isSearching = false;
  bool isLoading = true; // To handle loading state
  final List<Color> noteColors = [
    Colors.red.shade300,
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.yellow.shade300,
    Colors.orange.shade300,
  ]; // Predefined color list

  int colorIndex = 0; // To cycle through colors

  @override
  void initState() {
    super.initState();
    _readNotes(); // Fetch notes when the screen loads
  }

  Future<void> _readNotes() async {
    try {
      // Get the current user
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Get the user's email
        final String email = currentUser.email!;

        // Query the notes collection for the logged-in user, ordered by timestamp
        final querySnapshot = await FirebaseFirestore.instance
            .collection(email)
            .orderBy('timestamp', descending: true)
            .get();

        notes.clear(); // Clear existing notes before adding new ones

        // Loop through the fetched documents
        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          data['noteId'] = doc.id; // Store the document ID
          notes.add(data); // Add note to the list
        }

        setState(() {
          isLoading = false; // Stop the loader once notes are fetched
        });
      } else {
        print('No user is logged in.');
      }
    } catch (e) {
      print('Error reading notes: $e');
    }
  }

  // ignore: unused_element
  Future<void> _signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Also sign out from Google if the user was signed in via Google
      await GoogleSignIn().signOut();

      // Redirect to Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Sign out failed: $e")));
    }
  }

  // Function to handle the search input
  void _filterNotes(String query) {
    setState(() {
      if (query.isNotEmpty) {
        isSearching = true; // User is searching
        searchedNotes.clear();
        searchedNotes.addAll(notes.where((note) {
          final title = note['title'].toString().toLowerCase();
          final description = note['description'].toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return title.contains(searchLower) ||
              description.contains(searchLower);
        }).toList());
      } else {
        isSearching = false; // No search query, return to normal state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchText = value;
              _filterNotes(value); // Filter notes as the user types
            });
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while notes are being fetched
          : notes.isEmpty
              ? _buildEmptyState() // Show "+ Add Note" button when no notes are available
              : _buildNotesList(), // Show the list of notes when available
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Notesaddscreen(
                colorIndex: notes.length % noteColors.length, // Assign color based on index
              ),
            ),
          ).then((_) {
            _readNotes(); // Refresh notes after adding a new one
          });
        },
        child: Icon(
          Icons.add,
          size: 35,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Notesaddscreen(
                colorIndex: notes.length % noteColors.length, // Assign color based on index
              ),
            ),
          ).then((_) {
            _readNotes(); // Refresh notes after adding
          });
        },
        child: Text('+ Add Note'),
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: isSearching ? searchedNotes.length : notes.length,
      itemBuilder: (context, index) {
        final currentNote = isSearching ? searchedNotes[index] : notes[index];
        final noteColor = Color(currentNote['color'] ?? Colors.white.value); // Retrieve the color from Firestore

        return Card(
          color: noteColor, // Assign the color to the Card
          child: ListTile(
            title: Text(
              currentNote['title'] ?? 'Untitled',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detailnotesscreen(
                    noteId: currentNote['noteId'], // Pass noteId for editing
                    title: currentNote['title'],
                    description: currentNote['description'],
                  ),
                ),
              ).then((_) {
                _readNotes(); // Refresh the notes list after returning
              });
            },
          ),
        );
      },
    );
  }
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Container(
        color: Colors.teal[100], // Background color for the drawer
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Displaying the circular profile picture with shadow
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding:  EdgeInsets.only(top: 30.h),
                  child: CircleAvatar(
                    radius: 60, // Adjust size as needed
                    backgroundColor: Colors.white, // Background color of the circle
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!) // Load the profile image from Google
                          : AssetImage('assets/images/2stickyimg.png') as ImageProvider, // Placeholder image
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Displaying the welcome message with the user's name
            if (currentUser != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Welcome,\n${currentUser.displayName ?? currentUser.email}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40), // Vertical space
            Divider(thickness: 1, color: Colors.teal), // Divider line
            const SizedBox(height: 20),
            // Sign-out button
            ListTile(
              leading: Icon(
                Icons.logout_outlined,
                size: 40,
                color: Colors.teal,
              ),
              title: Text(
                'Sign out',
                style: TextStyle(fontSize: 20, color: Colors.teal[800]),
              ),
              onTap: () async {
                await _signOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the login screen or any desired screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Loginscreen()), // Change to your desired screen
    );
  }
}

