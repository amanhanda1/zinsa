import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zinsa/Theme/dark_mode.dart';
import 'package:zinsa/Theme/light_mode.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zinsa/firebase_options.dart';
import 'package:provider/provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const MyApp(),
    );
}
final storage = FirebaseStorage.instance;
final firestore = FirebaseFirestore.instance;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:const FirstPage(),
      theme:lightMode,
      darkTheme: darkMode,
    );
  }
}


  