import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Topic.dart'; // Import the Topic class
import 'package:studymatcherf/settings_page.dart'; // Import the SettingsPage to access dark mode setting
import '../Models/UserData.dart';
import 'create_group.dart'; // Import the CreateGroupPage

class SearchGroupsPage extends StatefulWidget {
  @override
  _SearchGroupsPageState createState() => _SearchGroupsPageState();
}

class _SearchGroupsPageState extends State<SearchGroupsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final bool _darkMode = true; // Manually manage dark mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Groups',
          style: TextStyle(
            color: _darkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            _darkMode ? Colors.black87 : Colors.grey.withOpacity(0.3),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _darkMode
                ? 'assets/images/black-wavy-background.jpg'
                : 'assets/images/white-wavy-background.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter group name',
                    prefixIcon: Icon(Icons.search),
                    hintStyle: TextStyle(
                      color: _darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onChanged: (value) {
                    setState(
                        () {}); // Trigger rebuild when search query changes
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('topics')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No groups found.'));
                    } else {
                      List<Topic> groups = snapshot.data!.docs
                          .map((doc) => Topic.fromMap(doc.data()!))
                          .toList();

                      // Filter groups based on search query
                      final query = _searchController.text.toLowerCase();
                      if (query.isNotEmpty) {
                        groups = groups
                            .where((group) => _containsSubstrings(
                                group.name.toLowerCase(), query))
                            .toList();
                      }

                      return ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          Topic topic = groups[index];
                          return GestureDetector(
                            onTap: () {
                              _joinGroup(topic.id);
                            },
                            child: ListTile(
                              title: Text(
                                topic.name,
                                style: TextStyle(
                                  color:
                                      _darkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              trailing: _buildJoinButton(topic),
                              // Add any other relevant information about the group
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to check if the group name contains any part of the query
  bool _containsSubstrings(String groupName, String query) {
    int queryIndex = 0;
    for (int i = 0; i < groupName.length; i++) {
      if (groupName[i] == query[queryIndex]) {
        queryIndex++;
        if (queryIndex == query.length) {
          return true;
        }
      }
    }
    return false;
  }

  Widget _buildJoinButton(Topic topic) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    bool isUserJoined = topic.joinedUsers.contains(userId);
    return ElevatedButton(
      onPressed: isUserJoined ? null : () => _joinGroup(topic.id),
      child: Text(isUserJoined ? 'Joined' : 'Join'),
    );
  }

  void _joinGroup(String groupId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(groupId)
          .update({
        'joinedUsers': FieldValue.arrayUnion([userId]),
      });
      // Show success message or navigate to a different page
    } catch (e) {
      print('Error joining group: $e');
      // Show error message
    }
  }
}
