import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zinsa/database/custom_unis.dart';

class UniversityListScreen extends StatefulWidget {
  const UniversityListScreen({super.key});

  @override
  UniversityListScreenState createState() => UniversityListScreenState();
}

class UniversityListScreenState extends State<UniversityListScreen> {
  String searchText = '';
  List<dynamic> universities = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> saveUniversityToFirestore(
      User? user, String universityName) async {
    if (user != null && user.email != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid!) // Assuming 'email' is the user identifier
          .set({
        'university': universityName,
      }, SetOptions(merge: true));
      print('University saved successfully!');
    }
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?name=$searchText'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> apiUniversities = json.decode(response.body);
      final customUniversities = CustomUniversities.getUniversities();

      // Commenting this line as it's not clear where 'CustomUniversities' is defined.
      // final customUniversities = CustomUniversities.getUniversities();

      setState(() {
        universities = [...apiUniversities,...customUniversities];
      });
    } else {
      throw Exception('Failed to load universities');
    }
  }

  List<dynamic> getFilteredUniversities() {
    // Filter universities based on the search text
    return universities
        .where((university) => university['name']
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = context.read<User?>();

    if (universities.isEmpty) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(206, 41, 152, 128),
        body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Loading the universities",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ));
    }

    List<dynamic> filteredUniversities = getFilteredUniversities();

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("ZINSA")],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                  fetchData();
                },
                decoration: const InputDecoration(
                  labelText: 'Search University',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            Expanded(
              child: filteredUniversities.isEmpty
                  ? const Center(
                      child: Text(
                        "No universities found",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredUniversities.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Color.fromARGB(125, 236, 239, 238),
                          child: ListTile(
                            title: Text(filteredUniversities[index]['name']!),
                            subtitle:
                                Text(filteredUniversities[index]['country']!),
                            onTap: () async {
                              // Pass the selected university back to the previous screen
                              Navigator.pop(
                                  context, filteredUniversities[index]['name']);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
