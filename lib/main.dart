import 'package:flutter/material.dart';
import 'login.dart'; // Import the login page
import 'personal_information.dart'; // Import the personal information page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => LoginScreen(), // Register the login page route
      },
      home: LoginScreen(),
    );
  }
}
