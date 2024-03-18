import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetWidget extends StatefulWidget {
  @override
  _PasswordResetWidgetState createState() => _PasswordResetWidgetState();
}

class _PasswordResetWidgetState extends State<PasswordResetWidget> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        // Password reset email sent successfully.
        // You may want to show a success message to the user.
      } catch (e) {
        // An error occurred while sending the password reset email.
        // You may want to show an error message to the user.
        print("Error sending password reset email: $e");
      }
    } else {
      // Handle the case where email is empty.
      print("Email cannot be empty.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Email",
          ),
        ),
        SizedBox(height: 16.0),
        GestureDetector(
          onTap: _resetPassword,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color.fromARGB(255, 241, 236, 236),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
