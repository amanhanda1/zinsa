import 'package:flutter/material.dart';
class UniversityDetailsScreen extends StatelessWidget {
  final String universityName;

  const UniversityDetailsScreen({Key? key, required this.universityName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: Text(universityName),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Details for $universityName',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}