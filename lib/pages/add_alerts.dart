import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAlertsPage extends StatefulWidget {
  @override
  _AddAlertsPageState createState() => _AddAlertsPageState();
}

class _AddAlertsPageState extends State<AddAlertsPage> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: Text('Add Alerts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(labelText: 'Add Alerts'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                var username = await _getUsername(currentUser!.uid ?? '');
                var university =
                    await _getUserUniversity(currentUser.uid ?? '');

                await FirebaseFirestore.instance.collection("Alerts").add({
                  'userId': currentUser.uid,
                  'text': _textController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                  'username': username,
                  'university': university,
                });

                Navigator.pop(context);
              },
              child: Text('add'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getUsername(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    var userData = userDoc.data() as Map<String, dynamic>?;

    return userData?['username'] ?? 'Unknown User';
  }

  Future<String> _getUserUniversity(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    var userData = userDoc.data() as Map<String, dynamic>?;

    return userData?['university'] ?? 'Unknown University';
  }
}
