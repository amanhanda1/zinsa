import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zinsa/components/mytextfield.dart';
import 'package:zinsa/components/error.dart';
import 'package:zinsa/components/showuniversities.dart';
import 'package:zinsa/login/log_in_with_google.dart';
import 'package:zinsa/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();
  DateTime? selectedDate;
  String? selectedUniversity;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:
                const Color.fromARGB(206, 5, 148, 117), // Set the primary color
            colorScheme:
                ColorScheme.light(primary: Color.fromARGB(206, 49, 50, 50)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void setUniversity(String university) {
    setState(() {
      selectedUniversity = university;
    });
  }

  void resisterUser() async {
    //loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    //confirming the password
    if (passwordController.text != cpasswordController.text) {
      Navigator.pop(context);
      displayerror("password does not match", context); //func from helper
    }
    //creating the user
    else {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        createUserDocument(userCredential, selectedDate, selectedUniversity);
        if (context.mounted) Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PostPage()));
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayerror(e.code, context);
      }
    }
  }

  Future<void> createUserDocument(
  UserCredential? userCredential,
  DateTime? dob,
  String? university,
) async {
  if (userCredential != null && userCredential.user != null) {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.uid) // Store user UID as document ID
        .set({
      'email': emailController.text,
      'uid': userCredential.user!.uid, // Store user UID
      'username': usernameController.text,
      'password': passwordController.text,
      'dob': dob,
      'university': university,
      'lastseen': FieldValue.serverTimestamp(),
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 5, 148, 117),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(height: 24),
              const Text("Z I N S A", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "UserName",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "abc@gmail.com",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 8),
              MyTextField(
                hintText: "Your password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 8),
              MyTextField(
                hintText: "confirm password",
                obscureText: true,
                controller: cpasswordController,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 43, 42, 42)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_month_sharp),
                        Text("   "),
                        Text("DoB"),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 43, 42, 42)),
                    ),
                    onPressed: () async {
                      // Navigate to university list and get the selected university
                      String? selectedUniversity = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UniversityListScreen(),
                        ),
                      );
                      setUniversity(selectedUniversity!);
                    },
                    child: const Text("SELECT YOUR UNIVERSITY"),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed: resisterUser,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all(const Size(999, 44)),
                ),
                child: const Text(
                  "SignUp",
                  style: TextStyle(
                    color: Color.fromARGB(255, 65, 64, 64),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GoogleSignInWidget()
            ],
          ),
        ),
      ),
    );
  }
}
