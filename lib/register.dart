import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart'; // Import the Login screen

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  // Function to handle registration logic and send data to the server
  Future<void> register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Check if all fields are filled
    if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      // Prepare data to send to the backend API
      final Map<String, String> userData = {
        'username': username,
        'email': email,
        'password': password,
      };

      // Replace with your actual API endpoint that will handle the registration
      final url = Uri.parse("http://192.168.254.129/capstone/register.php");

      // Send POST request to backend to insert data into the users table
      try {
        final response = await http.post(url, body: userData);

        // Decode the response from the server
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // Show success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Registration Successful"),
                content: Text("Your account has been created."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Redirect to login.dart
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          // Handle failure response
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Registration Failed"),
                content: Text(responseData['message']),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        // Handle network errors or any exceptions
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Something went wrong, please try again."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle case where fields are empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please fill in all fields."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: register, // Call the register function
              child: Text("Register"), // Changed to "Register"
            ),
          ],
        ),
      ),
    );
  }
}
