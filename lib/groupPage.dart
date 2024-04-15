import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studymatcherf/Models/UserData.dart';
import '../Models/Topic.dart';

class GroupPage extends StatefulWidget {
  final Topic topic;

  const GroupPage({required this.topic});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupPage> {
  final TextEditingController _messageController = TextEditingController();
  late String _userName;
  final bool _darkMode = true; // Manually manage dark mode

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    // Fetch user data from Firestore
    DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    // Extract the name field from the user data
    String? name = (userDataSnapshot.data() as Map<String, dynamic>?)?['name'];

    // Update the _userName state with the fetched name
    setState(() {
      _userName = name ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic.name,
          style: TextStyle(
            color: _darkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            _darkMode ? Colors.black : Colors.grey.withOpacity(0.3),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              'Users in Group',
              style: TextStyle(
                color: _darkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.topic.joinedUsers
                  .map((userId) =>
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              !snapshot.data!.exists) {
                            return Text('User not found');
                          } else {
                            var userData = snapshot.data!.data()!;
                            return Text(
                              '${userData['name']} (${userData['email']})',
                              style: TextStyle(
                                color: _darkMode ? Colors.white : Colors.black,
                              ),
                            );
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () => _leaveGroup(widget.topic.id),
            child: Text(
              'Leave Group',
              style: TextStyle(
                color: _darkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groupChats')
                  .doc(widget.topic.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(
                        color: _darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var messageData = snapshot.data!.docs[index].data()!;
                      var messageDataMap = messageData as Map<String, dynamic>;
                      return ListTile(
                        title: Text(
                          messageDataMap['text'] ?? '',
                          style: TextStyle(
                            color: _darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          messageDataMap['sender'] ?? 'Unknown',
                          style: TextStyle(
                            color: _darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type your message',
                      labelStyle: TextStyle(
                        color: _darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(widget.topic.id),
                  color: _darkMode ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String groupId) async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(groupId)
          .collection('messages')
          .add({
        'text': messageText,
        'sender': _userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      // Handle error
    }
  }

  void _leaveGroup(String groupId) async {
    try {
      // Remove the current user's ID from the joinedUsers list
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(groupId)
          .update({
        'joinedUsers':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });

      // Navigate back to previous screen or handle navigation as needed
      Navigator.pop(context);
    } catch (e) {
      print('Error leaving group: $e');
      // Handle error
    }
  }
}
