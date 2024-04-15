import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateGroupPage extends StatelessWidget {
  final TextEditingController topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool _darkMode = true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            _darkMode ? Colors.black87 : Colors.grey.withOpacity(0.3),
        elevation: 0, // No shadow
        centerTitle: true,

        title: Text(
          'Create Your Own Group',
          style: TextStyle(
            color: _darkMode ? Colors.white : Colors.deepPurple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: _darkMode
                  ? Colors.white
                  : Colors.deepPurple), // Change color based on mode
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back when pressed
          },
        ),
      ),

      extendBodyBehindAppBar: true, // Extend the background behind the app bar
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_darkMode
                ? 'assets/images/black-wavy-background.jpg'
                : 'assets/images/white-wavy-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: topicController,
                  style: TextStyle(
                      color: _darkMode
                          ? Colors.white
                          : Colors.black), // Text color based on mode
                  decoration: InputDecoration(
                    labelText: 'Enter Title',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelStyle: TextStyle(
                      color: _darkMode
                          ? Colors.white
                          : Colors.deepPurple, // Label color based on mode
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _darkMode
                              ? Colors.grey
                              : Colors.grey), // Border color based on mode
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _darkMode
                              ? Colors.grey
                              : Colors.grey), // Border color based on mode
                    ),
                    filled: true,
                    fillColor: _darkMode
                        ? Color.fromARGB(255, 33, 33, 33)
                        : Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _createGroup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkMode
                        ? Colors.white.withOpacity(
                            0.9) // Light background color with opacity
                        : Colors.black
                            .withOpacity(0.9), // Deep purple background color
                    elevation: 4,
                    shape: CircleBorder(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      'icons/add_group1.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createGroup(BuildContext context) async {
    String topicName = topicController.text.trim();

    if (topicName.isEmpty) {
      _showErrorDialog(context, 'Error', 'Please enter a topic.');
      return;
    }

    try {
      String topicId = FirebaseFirestore.instance.collection('topics').doc().id;
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('topics').doc(topicId).set({
        'id': topicId,
        'name': topicName,
        'createdBy': userId,
        'joinedUsers': [userId],
      });

      _showSuccessDialog(context);
    } catch (e) {
      print('Error creating group: $e');
      _showErrorDialog(
          context, 'Error', 'Failed to create group. Please try again later.');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Group created successfully!'),
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
