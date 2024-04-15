import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/Topic.dart';
import 'groupPage.dart';

class MyGroupsPage extends StatelessWidget {
  final bool _darkMode = true; // Manually manage dark mode

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Groups',
          style: TextStyle(
            color: _darkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            _darkMode ? Colors.black : Colors.grey.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _darkMode
                  ? 'assets/images/black-wavy-background.jpg'
                  : 'assets/images/white-wavy-background.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Object?>>(
          stream: FirebaseFirestore.instance
              .collection('topics')
              .where('joinedUsers', arrayContains: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No groups found.',
                  style: TextStyle(
                    color: _darkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot<Map<String, dynamic>> groupSnapshot =
                      snapshot.data!.docs[index]
                          as QueryDocumentSnapshot<Map<String, dynamic>>;
                  Topic topic = Topic.fromMap(groupSnapshot.data());
                  return ListTile(
                    title: Text(
                      topic.name,
                      style: TextStyle(
                        color: _darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupPage(topic: topic),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
