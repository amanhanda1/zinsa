import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class UniversitySearchWidget extends StatefulWidget {
  final void Function(String selectedUniversity) onUniversitySelected;

  const UniversitySearchWidget({Key? key, required this.onUniversitySelected}) : super(key: key);

  @override
  _UniversitySearchWidgetState createState() => _UniversitySearchWidgetState();
}

class _UniversitySearchWidgetState extends State<UniversitySearchWidget> {
  String searchText = '';
  List<dynamic> universities = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?name=$searchText'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> apiUniversities = json.decode(response.body);

      setState(() {
        universities = apiUniversities;
      });
    } else {
      throw Exception('Failed to load universities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
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
        const SizedBox(height: 16),
        Expanded(
          child: universities.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: universities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(universities[index]['name']!),
                      subtitle: Text(universities[index]['country']!),
                      onTap: () async {
                        // Callback to parent widget with selected university
                        widget.onUniversitySelected(universities[index]['name']!);
                        // Add university to Firestore if needed
                        await saveUniversityToFirestore(universities[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('University added to Firestore!'),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> saveUniversityToFirestore(Map<String, dynamic> university) async {
    // Add the logic to store the university in Firestore
    await FirebaseFirestore.instance.collection("university").add({
      'name': university['name'],
      // Add more fields if needed
    });
  }
}