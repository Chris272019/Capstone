import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInformationPage extends StatefulWidget {
  @override
  _PersonalInformationPageState createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController middlenameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController civilStatusController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController houseNoController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController officeAddressController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController telephoneNumberController =
  TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController schoolIdentificationController =
  TextEditingController();
  final TextEditingController companyIdentificationController =
  TextEditingController();
  final TextEditingController prcIdentificationController =
  TextEditingController();
  final TextEditingController driversIdentificationController =
  TextEditingController();
  final TextEditingController sssGsisBirController = TextEditingController();

  String username = '';

  @override
  void initState() {
    super.initState();
    _getUsernameFromSharedPreferences();
  }

  // Get the username from shared preferences
  Future<void> _getUsernameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? ''; // Default to empty if no username is found
    });
  }

  // Function to send data to the PHP server
  Future<void> submitForm(String username) async {
    final response = await http.post(
      Uri.parse('http://192.168.254.129/capstone/update_user.php'), // Replace with your PHP endpoint
      body: {
        'username': username, // Send the username to identify the user
        'surname': surnameController.text,
        'firstname': firstnameController.text,
        'middlename': middlenameController.text,
        'birthdate': birthdateController.text,
        'age': ageController.text,
        'civil_status': civilStatusController.text,
        'sex': sexController.text,
        'house_no': houseNoController.text,
        'street': streetController.text,
        'barangay': barangayController.text,
        'town': townController.text,
        'province': provinceController.text,
        'zipcode': zipCodeController.text,
        'office_address': officeAddressController.text,
        'nationality': nationalityController.text,
        'religion': religionController.text,
        'education': educationController.text,
        'occupation': occupationController.text,
        'telephone_number': telephoneNumberController.text,
        'mobile_number': mobileNumberController.text,
        'school_identification': schoolIdentificationController.text,
        'company_identification': companyIdentificationController.text,
        'prc_identification': prcIdentificationController.text,
        'drivers_identification': driversIdentificationController.text,
        'sss_gsis_bir': sssGsisBirController.text,
      },
    );

    if (response.statusCode == 200) {
      // Handle successful response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Information updated successfully')),
      );

      // Redirect to login page after success
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Handle error response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update information')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextFormField(surnameController, 'Surname'),
                buildTextFormField(firstnameController, 'First Name'),
                buildTextFormField(middlenameController, 'Middle Name'),
                buildTextFormField(birthdateController, 'Birthdate'),
                buildTextFormField(ageController, 'Age'),
                buildTextFormField(civilStatusController, 'Civil Status'),
                buildTextFormField(sexController, 'Sex'),
                buildTextFormField(houseNoController, 'House No'),
                buildTextFormField(streetController, 'Street'),
                buildTextFormField(barangayController, 'Barangay'),
                buildTextFormField(townController, 'Town'),
                buildTextFormField(provinceController, 'Province'),
                buildTextFormField(zipCodeController, 'Zip Code'),
                buildTextFormField(officeAddressController, 'Office Address'),
                buildTextFormField(nationalityController, 'Nationality'),
                buildTextFormField(religionController, 'Religion'),
                buildTextFormField(educationController, 'Education'),
                buildTextFormField(occupationController, 'Occupation'),
                buildTextFormField(telephoneNumberController, 'Telephone Number'),
                buildTextFormField(mobileNumberController, 'Mobile Number'),
                buildTextFormField(schoolIdentificationController, 'School ID'),
                buildTextFormField(companyIdentificationController, 'Company ID'),
                buildTextFormField(prcIdentificationController, 'PRC ID'),
                buildTextFormField(driversIdentificationController, 'Driver\'s License'),
                buildTextFormField(sssGsisBirController, 'SSS/GIS/BIR ID'),
                SizedBox(height: 20),
                // Submit Button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        submitForm(username); // Use the retrieved username
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create a TextFormField with validation
  Widget buildTextFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
