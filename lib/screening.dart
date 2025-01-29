import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Screening extends StatefulWidget {
  @override
  _ScreeningFormState createState() => _ScreeningFormState();
}

class _ScreeningFormState extends State<Screening> {
  String username = ''; // To store the username
  bool isFemale = false; // Track whether the user is female to show additional questions

  // Map to store answers for general questions (with Yes/No options)
  Map<String, bool> answers = {
    'Q1: Do you feel well and healthy today?': false,
    'Q2: Have you ever been refused as a blood donor?': false,
    'Q3: Are you giving blood only to be tested for HIV or Hepatitis?': false,
    'Q4: Are you aware of HIV/Hepatitis transmission despite a negative test?': false,
    'Q5: Taken alcohol in the last 12 hours?': false,
    'Q6: Taken aspirin in the last 3 days?': false,
    'Q7: Medications or vaccines in the last 8 weeks?': false,
    'Q8: Donated blood in the past 3 months?': false,
    'Q9: Visited Zika-infected areas in the past 6 months?': false,
    'Q10: Had sexual contact with a Zika-infected person?': false,
    'Q11: Received blood or had surgery in the last 12 months?': false,
    'Q12: Tattoo, piercing, or contact with blood in the last 12 months?': false,
    'Q13: High-risk sexual contact in the last 12 months?': false,
    'Q14: Had jaundice or hepatitis, or been incarcerated?': false,
    'Q15: Traveled outside your country of residence?': false,
    'Q16: Taken prohibited drugs?': false,
    'Q17: Had a positive test for HIV, Hepatitis, or Syphilis?': false,
    'Q18: Had Malaria or Hepatitis in the past?': false,
    'Q19: Had sexually transmitted diseases?': false,
    'Q20: Cancer, heart disease, or blood disorders?': false,
    'Q21: Tuberculosis, asthma, or lung diseases?': false,
    'Q22: Kidney disease, diabetes, or epilepsy?': false,
    'Q23: Chickenpox or cold sores?': false,
    'Q24: Other chronic medical conditions?': false,
    'Q25: Recently had a rash or fever?': false,
  };

  // Female-specific questions
  Map<String, String> femaleAnswers = {
    'Q26: Are you currently pregnant or have you ever been pregnant?': '',
    'Q27: When was your last childbirth?': '',
    'Q28: Did you have a miscarriage or abortion in the last year?': '',
    'Q29: Are you currently breastfeeding?': '',
    'Q30: When was your last menstrual period?': '',
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Function to initialize the data
  Future<void> _initializeData() async {
    await _getUsername();
  }

  // Function to get the username from SharedPreferences
  Future<void> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Unknown'; // Default to 'Unknown' if no username is found
    });
  }

  // Function to submit the form
  Future<void> _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username'); // Get username from SharedPreferences

    if (username == null || username.isEmpty) {
      print('Username is not available.');
      return;
    }

    // Get the id based on the username
    String userId = await _getIdByUsername(username);
    if (userId.isEmpty) {
      print('User ID is not available.');
      return;
    }

    // Prepare data to send to PHP
    Map<String, String> data = {
      'user_id': userId, // Now passing the retrieved id
      'is_female': isFemale ? 'true' : 'false', // Pass the gender as varchar (string)
    };

    // Add general answers (Q1 to Q25) and convert boolean answers to 'Yes' or 'No' (varchar)
    for (int i = 1; i <= 25; i++) {
      String questionKey = answers.keys.elementAt(i - 1); // Correctly map the question key
      data['Q$i'] = (answers[questionKey] ?? false) ? 'Yes' : 'No'; // Convert boolean to 'Yes'/'No'
    }


    // Add female-specific answers if applicable (Q26 to Q30)
    if (isFemale) {
      int index = 26;
      for (var question in femaleAnswers.keys) {
        data['Q$index'] = femaleAnswers[question] ?? ''; // Ensure the value is a string
        index++;
      }
    }

    // Send data to PHP backend
    var response = await http.post(
      Uri.parse('http://192.168.254.129/capstone/submit_screening.php'),
      body: data,
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        // Handle success
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Your answers have been saved successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to save data: ${responseData['message']}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Failed to connect to the server.');
    }
  }

// Function to get the id based on the username
  Future<String> _getIdByUsername(String username) async {
    var response = await http.post(
      Uri.parse('http://192.168.254.129/capstone/get_user_id.php'), // Your PHP script to get the id
      body: {'username': username},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        return responseData['id']; // Return the id
      } else {
        print('Failed to retrieve user id: ${responseData['message']}');
        return '';
      }
    } else {
      print('Failed to connect to the server.');
      return '';
    }
  }


  // Function to set answers to Yes/No for general questions
  void setAnswer(String question, bool value) {
    setState(() {
      answers[question] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Blood Donation Screening Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display username
            Text('Hello, $username!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            // Gender selection to conditionally show female-specific questions
            Row(
              children: [
                Text("Are you female?"),
                Switch(
                  value: isFemale,
                  onChanged: (bool value) {
                    setState(() {
                      isFemale = value;
                    });
                  },
                ),
              ],
            ),

            // Show general questions (Q1 to Q25)
            ...answers.keys.map((question) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question),
                  Row(
                    children: [
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: answers[question],
                            onChanged: (bool? value) {
                              setAnswer(question, value ?? false);
                            },
                          ),
                          Text('Yes'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: answers[question],
                            onChanged: (bool? value) {
                              setAnswer(question, value ?? false);
                            },
                          ),
                          Text('No'),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),

            // Show female-specific questions (Q26 to Q30)
            if (isFemale)
              ...femaleAnswers.keys.map((question) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          femaleAnswers[question] = value;
                        });
                      },
                    ),
                  ],
                );
              }).toList(),

            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
