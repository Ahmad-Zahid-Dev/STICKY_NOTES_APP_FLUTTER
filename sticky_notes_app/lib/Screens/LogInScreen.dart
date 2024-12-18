import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sticky_notes_app/Screens/HomeScreen.dart'; // Import HomeScreen
import 'package:sticky_notes_app/Screens/SignUpScreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool _isObscured = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email/Password Login
  Future<void> _loginWithEmailPassword() async {
  try {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email and Password cannot be empty")),
      );
      return;
    }

    await _auth.signInWithEmailAndPassword(email: email, password: password);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logged in successfully!")),
    );

    // Redirect to HomeScreen after successful login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homescreen()),
    );
  } on FirebaseAuthException catch (e) {
    // Show specific error message based on the error code
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = "No user found for that email. Please sign up.";
        break;
      case 'wrong-password':
        errorMessage = "Incorrect password. Please try again.";
        break;
      case 'invalid-email':
        errorMessage = "The email address is not valid.";
        break;
      default:
        errorMessage = "Login failed. Please try again.";
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


  // Google Login
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the login process
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged in with Google!")));

      // Redirect to HomeScreen after successful Google Login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homescreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Login failed: $e")));
    }
  }

  // Forgot Password
  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter your email to reset the password")));
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password reset email sent! Check your inbox.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
                'Login',
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w500),
              ),
            ),
            30.verticalSpace,
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
            10.verticalSpace,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword, // Call the forgot password function
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            20.verticalSpace,
            Container(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  _loginWithEmailPassword(); // Email/Password Login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            10.verticalSpace,
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Signupscreen()));
              },
              child: Text(
                "Don't have an account? Sign Up",
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
                  _loginWithGoogle(); // Google Login
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
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                    Text(
                      'Log in with Google',
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
