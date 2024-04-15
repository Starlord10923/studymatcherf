import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studymatcherf/Components/my_button.dart';
import 'package:studymatcherf/Components/square_tile.dart';
import 'package:studymatcherf/Components/my_textfield.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              const Icon(
                Icons.lock,
                size: 100,
              ),

              Text(
                "Welcome to Study Group Matcher",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              //Username Textfield
              MyTextField(
                controller: emailController,
                hintText: "E-mail",
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //Password Textfield
              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              const SizedBox(height: 20),

              //Login Button
              MyButton(
                onTap: () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    _showErrorDialog(
                        context, 'Error', 'Please fill in all fields.');
                    return;
                  }

                  try {
                    UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (userCredential.user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      _showErrorDialog(
                          context, 'Error', 'Invalid email or password.');
                    }
                  } catch (e) {
                    print('Error signing in: $e');
                    String errorMessage =
                        'An error occurred. Please try again later.';
                    if (e is FirebaseAuthException) {
                      switch (e.code) {
                        case 'invalid-email':
                          errorMessage = 'Invalid email address format.';
                          break;
                        case 'user-not-found':
                          errorMessage =
                              'User not found. Please check your email.';
                          break;
                        case 'wrong-password':
                          errorMessage = 'Invalid password. Please try again.';
                          break;
                        case 'invalid-credential':
                          errorMessage = 'Invalid authentication credentials.';
                          break;
                        default:
                          errorMessage =
                              'An error occurred. Please try again later.';
                      }
                    }
                    _showErrorDialog(context, 'Error', errorMessage);
                  }
                },
              ),

              const SizedBox(height: 50),

              //Or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              //Button for Sign in through Google
              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(
                      onTap: () => _signInWithGoogle(context),
                      imagePath: 'assets/images/google.png'),
                ],
              ),

              //Register Text Button

              const SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not a Member?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Register Now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in the user with the Google credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      // Check if the user exists in the Firestore database
      DocumentSnapshot<Map<String, dynamic>> userDataSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      if (userDataSnapshot.exists) {
        // User exists, navigate to home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User doesn't exist, display account not found alert
        _showErrorDialog(context, 'Account Not Found',
            'This Google account is not registered.');
      }
    } catch (error) {
      print('Error signing in with Google: $error');
      // Handle error here
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
