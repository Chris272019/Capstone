import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screening.dart'; // Import Screening.dart

class Homepage extends StatefulWidget {
  @override
  _HomepagePageState createState() => _HomepagePageState();
}

class _HomepagePageState extends State<Homepage> {
  String username = '';
  String firstName = '';
  String surname = '';
  String lastDonation = 'Not Donated Yet'; // Placeholder for last donation date
  String nextDonation = 'Not Scheduled'; // Placeholder for next donation date
  int _currentIndex = 0; // Track the current index of the bottom navigation bar
  List posts = []; // List to hold community posts

  @override
  void initState() {
    super.initState();
    _getUsernameFromSharedPreferences();
    _fetchPosts(); // Fetch posts during initialization
  }

  // Get username from SharedPreferences
  Future<void> _getUsernameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? ''; // Default to empty if no username is found
    });
    if (username.isNotEmpty) {
      _fetchUserInfo();
    }
  }

  // Fetch user info from PHP backend
  Future<void> _fetchUserInfo() async {
    final response = await http.post(
      Uri.parse('http://192.168.254.129/capstone/fetch_user_info.php'),
      body: {'username': username},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        firstName = data['firstname'];
        surname = data['surname'];
        lastDonation = data['last_donation'] ?? 'Not Donated Yet';
        nextDonation = data['next_donation'] ?? 'Not Scheduled';
      });
    } else {
      print('Failed to fetch user information');
    }
  }

  // Fetch community posts from PHP backend
  Future<void> _fetchPosts() async {
    final response = await http.get(
      Uri.parse('http://192.168.254.129/capstone/process_fetch_post.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          posts = data['posts']; // Extract 'posts' array from response
        });
      } else {
        print('No posts available');
      }
    } else {
      print('Failed to fetch posts');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donor Profile')),
      body: _currentIndex == 0 ? _buildCommunity() : _buildProfile(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Build Community section
  Widget _buildCommunity() {
    return posts.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        return Card(
          margin: EdgeInsets.all(10),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  post['title'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Image.network(
                post['image_path'] ?? '', // Use an empty string if 'image_path' is null
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey, // Placeholder background for broken images
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  post['description'],
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Posted by: ${post['username']}',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build Profile section
  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile container
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $surname',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Username: $username',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Blood Donation Info Container
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blood Donation Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Last Donation: $lastDonation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Next Donation: $nextDonation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Actionable Buttons
                  Column(
                    children: [
                      _buildButtonWithIcon(Icons.history, 'Donation History'),
                      SizedBox(height: 15),
                      _buildButtonWithIcon(Icons.schedule, 'Schedule Donation'),
                      SizedBox(height: 15),
                      _buildButtonWithIcon(Icons.card_membership, 'Donor Card'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create a button with an icon
  Widget _buildButtonWithIcon(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == 'Schedule Donation') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Screening()),
          );
        }
        print('$label button pressed');
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
