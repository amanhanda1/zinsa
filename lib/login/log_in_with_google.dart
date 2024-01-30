import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      print("Signed in with Google: ${user!.displayName}");

      return user;
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
  onPressed: () async {
    User? user = await _handleSignIn();
    // Handle the signed-in user as needed
  },
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 20, 30, 209)), // Change to your desired blue color
    minimumSize: MaterialStateProperty.all(const Size(545, 44)),
    alignment: Alignment.center, // Center the content within the button
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start, // Start the content from the beginning
    children: [
      Image.asset(
        'assets/appimages/google_logo.png', // Replace with the path to your Google logo asset
        height: 24.0, // Adjust the height as needed
      ),
      const SizedBox(
        width: 8.0,
      ), // Add some spacing between the logo and text
      const Expanded(
        child: Text(
          'GOOGLE',
          textAlign: TextAlign.center, // Center the text within the available space
          style: TextStyle(
            color: Colors.white, // Change text color to white
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
);


  }
}
