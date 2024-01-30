import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class HobbiesWidget extends StatefulWidget {
  final String userId;
  final bool isOwnProfile; // Add this parameter

  const HobbiesWidget({Key? key, required this.userId, required this.isOwnProfile}) : super(key: key);

  @override
  _HobbiesWidgetState createState() => _HobbiesWidgetState();
}

class _HobbiesWidgetState extends State<HobbiesWidget> {
  TextEditingController _newHobbyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Selected Hobbies:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("Users").doc(widget.userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Text("User data not found");
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final List<dynamic> hobbies = userData['hobbies'] ?? [];

            return Column(
              children: [
                
                if (widget.isOwnProfile) // Only show the add hobby option for own profile
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            controller: _newHobbyController,
                            decoration: const InputDecoration(
                              hintText: "Enter hobby",
                            ),
                            onFieldSubmitted: (newHobby) {
                              addHobbyToFirestore(widget.userId, newHobby);
                              _newHobbyController.clear();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_newHobbyController.text.isNotEmpty) {
                            addHobbyToFirestore(widget.userId, _newHobbyController.text);
                            _newHobbyController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    for (var hobby in hobbies)
                      _buildHobbyItem(hobby),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHobbyItem(String hobby) {
    final randomColor = _generateRandomColor();

    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context, hobby),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: randomColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(hobby,style:const TextStyle(color:Colors.white)),
      ),
    );
  }

  Color _generateRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String hobby) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Hobby",style:TextStyle(color:Colors.black)),
          content: Text("Are you sure you want to delete '$hobby'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel",style:TextStyle(color:Colors.black)),
            ),
            TextButton(
              onPressed: () {
                removeHobbyFromFirestore(widget.userId, hobby);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Delete",style:TextStyle(color:Colors.black),),
            ),
          ],
        );
      },
    );
  }

  Future<void> addHobbyToFirestore(String userId, String newHobby) async {
    await FirebaseFirestore.instance.collection("Users").doc(userId).update({
      'hobbies': FieldValue.arrayUnion([newHobby]),
    });
  }

  Future<void> removeHobbyFromFirestore(String userId, String hobby) async {
    await FirebaseFirestore.instance.collection("Users").doc(userId).update({
      'hobbies': FieldValue.arrayRemove([hobby]),
    });
  }
}