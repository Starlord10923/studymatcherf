import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _darkMode = true;
  late Color _textColor;
  late String _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  void _loadDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _updateTheme();
    });
  }

  void _toggleDarkMode(bool newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = newValue;
      prefs.setBool('darkMode', newValue);
      _updateTheme();
    });
  }

  void _updateTheme() {
    setState(() {
      _textColor = _darkMode ? Colors.white : Colors.black;
      _backgroundImage = _darkMode
          ? 'images/black-wavy-background.jpg'
          : 'images/white-wavy-background.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: _textColor),
        ),

        backgroundColor:
            _darkMode ? Colors.black87 : Colors.grey.withOpacity(0.3),
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor), // Set icon color
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            _backgroundImage,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: 20, color: _textColor),
                ),
                Switch(
                  value: _darkMode,
                  onChanged: _toggleDarkMode,
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
