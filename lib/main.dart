import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zinsa/Theme/dark_mode.dart';
import 'package:zinsa/Theme/light_mode.dart';
import 'package:zinsa/firebase_options.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/login_page.dart'; // Import your login page
import 'package:zinsa/pages/home_page.dart'; // Import your home page
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Check if the user is already signed in
  User? user = FirebaseAuth.instance.currentUser;
  Widget initialScreen = (user != null) ? PostPage() : FirstPage();

  runApp(MyApp(initialScreen: initialScreen));
}
final storage = FirebaseStorage.instance;
final firestore = FirebaseFirestore.instance;

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Z I N S A',
      theme:lightMode,
      darkTheme: darkMode,
      home: initialScreen,
    );
  }
}
