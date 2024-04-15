import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studymatcherf/create_group.dart';
import 'package:studymatcherf/MyGroupsPage.dart';
import 'package:studymatcherf/groupPage.dart';
import 'package:studymatcherf/home_page.dart';
import 'package:studymatcherf/login_page.dart';
import 'package:studymatcherf/profile_page.dart';
import 'package:studymatcherf/register_page.dart';
import 'package:studymatcherf/searchgroups_page.dart'; // Add import for SearchGroupsPage
import 'package:studymatcherf/settings_page.dart'; // Add import for SettingsPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Add your Firebase options here
    options: FirebaseOptions(
      apiKey: "AIzaSyBRIUSFtmqyD4xLG-yInVFKraYFiCIVXgQ",
      authDomain: "groupstudyplanner-96c44.firebaseapp.com",
      databaseURL:
          "https://groupstudyplanner-96c44-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "groupstudyplanner-96c44",
      storageBucket: "groupstudyplanner-96c44.appspot.com",
      messagingSenderId: "140410400136",
      appId: "1:140410400136:web:c113da348491650dbd5e3d",
      measurementId: "G-EJ23GH0CDK",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMatcher',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => ProfilePage(),
        '/createGroup': (context) => CreateGroupPage(),
        '/searchGroups': (context) => SearchGroupsPage(),
        '/settings': (context) => SettingsPage(),
        '/myGroups': (context) => MyGroupsPage(),
      },
      home: SplashScreen(), // Set the home property to SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login page after 2 seconds
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Opacity(
          opacity: 0.95, // Adjust the opacity value as needed
          child: Image.asset(
            "assets/images/crystal.jpeg",
            width: 600, // Adjust the width and height as needed
            height: 600,
          ),
        ),
      ),
    );
  }
}
