import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sticky_notes_app/Screens/HomeScreen.dart';
import 'package:sticky_notes_app/Screens/SignUpScreen.dart'; // Import SignupScreen

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();

    // Check the authentication status
    Future.delayed(Duration(seconds: 3), () {
      _checkAuthState();
    });
  }

  // Check if user is logged in or not
  void _checkAuthState() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If the user is logged in, navigate to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } else {
      // If the user is not logged in, navigate to the SignUpScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Signupscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff95E5E5),
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            child: Image.asset(
              "assets/images/2stickyimg.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
