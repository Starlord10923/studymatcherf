import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studymatcherf/settings_page.dart'; // Import the SettingsPage to access dark mode setting
import '../Models/UserData.dart';
import 'create_group.dart'; // Import the CreateGroupPage

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool _darkMode = true;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: _darkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            _darkMode ? Colors.black87 : Colors.grey.withOpacity(0.3),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: _darkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: _darkMode ? Colors.black87 : Colors.grey.withOpacity(0.3),
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                UserData userData = UserData.fromJson(snapshot.data!.data()!);
                return ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: _darkMode
                            ? Colors.black87
                            : Colors.grey.withOpacity(0.3),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/crystal.jpeg"),
                            radius: 46,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userData.name,
                                  style: TextStyle(
                                    color:
                                        _darkMode ? Colors.white : Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text('Create Group',
                          style: TextStyle(
                              color: _darkMode ? Colors.white : Colors.black)),
                      onTap: () {
                        Navigator.pushNamed(context, '/createGroup');
                      },
                    ),
                    ListTile(
                      title: Text('Search Groups',
                          style: TextStyle(
                              color: _darkMode ? Colors.white : Colors.black)),
                      onTap: () {
                        Navigator.pushNamed(context, '/searchGroups');
                      },
                    ),
                    ListTile(
                      title: Text('My Groups',
                          style: TextStyle(
                              color: _darkMode ? Colors.white : Colors.black)),
                      onTap: () {
                        Navigator.pushNamed(context, '/myGroups');
                      },
                    ),
                    ListTile(
                      title: Text('Settings',
                          style: TextStyle(
                              color: _darkMode ? Colors.white : Colors.black)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()),
                        ); // Navigate to SettingsPage
                      },
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Log Out',
                          style: TextStyle(
                              color: _darkMode ? Colors.white : Colors.black)),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_darkMode
                ? 'assets/images/black-wavy-background.jpg'
                : 'assets/images/white-wavy-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  heightFactor: 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconButton(
                            Icons.add,
                            'Create Group',
                            () {
                              Navigator.pushNamed(context, '/createGroup');
                            },
                            _darkMode ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconButton(
                            Icons.group,
                            'My Groups',
                            () {
                              Navigator.pushNamed(context, '/myGroups');
                            },
                            _darkMode ? Colors.white : Colors.black,
                          ),
                          _buildIconButton(
                            Icons.search,
                            'Search Groups',
                            () {
                              Navigator.pushNamed(context, '/searchGroups');
                            },
                            _darkMode ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconButton(
                            Icons.settings,
                            'Settings',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsPage()),
                              ); // Navigate to SettingsPage
                            },
                            _darkMode ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, String label, void Function()? onTap, Color color) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 16,
                offset: Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16.5,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: 60,
              color: color,
            ),
            onPressed: onTap,
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }
}
