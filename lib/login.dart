import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'homepage.dart'; // Import the HomePage
import 'register.dart'; // Import the RegisterScreen
import 'personal_information.dart'; // Import the PersonalInformationScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Function to handle login and store username in SharedPreferences
  Future<void> login() async {
    final url = Uri.parse("http://192.168.254.129/capstone/login.php"); // Replace with your API endpoint
    final response = await http.post(
      url,
      body: {
        'username': _usernameController.text,
        'password': _passwordController.text,
      },
    );

    final responseData = json.decode(response.body);

    if (responseData['status'] == 'success') {
      // Save the username in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', _usernameController.text); // Save the username

      // Check if personal information is filled
      bool hasPersonalInfo = responseData['hasPersonalInfo'];

      if (hasPersonalInfo) {
        // Navigate to HomePage if login is successful and personal info is filled
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        // Redirect to personal information page if personal info is missing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PersonalInformationPage()),
        );
      }
    } else {
      // Handle login failure
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login Failed"),
            content: Text(responseData['message']),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
            children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text("Login"),
            ),
            SizedBox(height: 20),
            // 'Don't have an account?' text and the 'Register' button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                TextButton(
                  onPressed: () {
                    // Navigate to the RegisterScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text("Register here."),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
