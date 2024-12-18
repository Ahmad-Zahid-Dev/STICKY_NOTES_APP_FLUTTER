import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sticky_notes_app/Screens/HomeScreen.dart'; // Ensure HomeScreen is imported
import 'package:sticky_notes_app/Screens/LogInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool _isObscured = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email/Password Sign-Up
  Future<void> _signUpWithEmailPassword() async {
  try {
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username, Email, and Password cannot be empty")),
      );
      return;
    }

    // Create user in Firebase Authentication
    // ignore: unused_local_variable
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Verify that user is signed in
    if (_auth.currentUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed up successfully!")),
      );

      // Redirect to HomeScreen after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    }
  } on FirebaseAuthException catch (e) {
    // Show specific error message based on the error code
    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = "The email is already in use. Please log in instead.";
        break;
      case 'weak-password':
        errorMessage = "The password provided is too weak.";
        break;
      case 'invalid-email':
        errorMessage = "The email address is not valid.";
        break;
      default:
        errorMessage = "Sign up failed. Please try again.";
    } 
  

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    // Display a generic error message for other exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred. Please try again.")),
    );
  }
}



  // Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed up with Google!"))
      );

      // Redirect to HomeScreen after successful Google Sign-Up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $e"))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
             child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w500),
              ),
            ),
            30.verticalSpace,
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            15.verticalSpace,
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            15.verticalSpace,
            TextField(
              controller: _passwordController,
              obscureText: _isObscured, // Hide the password
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility, // Toggle eye icon
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured; // Toggle the password visibility
                    });
                  },
                ),
              ),
            ),
            20.verticalSpace,
            Container(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  _signUpWithEmailPassword(); // Email/Password Sign-Up
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            10.verticalSpace,
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Loginscreen()));
              },
              child: Text(
                "Already have an account? Log In",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            10.verticalSpace,
            Divider(),
            10.verticalSpace,
            Container(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: () {
                  _signInWithGoogle(); // Trigger Google Sign-In
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        "assets/images/google.png",
                        fit: BoxFit.contain,
                        width: 30.w,
                        height: 30.h,
                      ),
                    ),
                    Text(
                      'Sign up with Google',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
