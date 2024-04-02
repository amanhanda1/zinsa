import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsRegistrationPage extends StatelessWidget {
  final String? eventId;

  const EventsRegistrationPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: const Text("Register for the Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventRegistrationForm(eventId: eventId),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Registered Users:',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            RegisteredUsersList(eventId: eventId),
          ],
        ),
      ),
    );
  }
}

class EventRegistrationForm extends StatefulWidget {
  final String? eventId;

  const EventRegistrationForm({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventRegistrationFormState createState() => _EventRegistrationFormState();
}

class _EventRegistrationFormState extends State<EventRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? department;

  Future<void> createEvent() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .get();
      if (department != null) {
        final eventRef = FirebaseFirestore.instance.collection('Events').doc(widget.eventId.toString());
        final registrationData = {
          'name': userSnapshot['username'],
          'email': userSnapshot['email'],
          'department': department,
          'userId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(), // Include a timestamp for sorting purposes
        };
        await eventRef.collection('Registrations').add(registrationData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful ")),
        );
        // Don't need to navigate back here
      } else {
        print('Please fill all fields');
      }
    } catch (e) {
      print('Error creating event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Department',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your department';
              }
              return null;
            },
            onSaved: (value) {
              department = value;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.orange.shade800,
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                createEvent();
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

class RegisteredUsersList extends StatelessWidget {
  final String? eventId;

  const RegisteredUsersList({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Events')
          .doc(eventId)
          .collection('Registrations')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No users registered yet');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var userName = data['name'];
            var timestamp = data['timestamp']?.toDate();
            return ListTile(
              title: Text(userName),
              subtitle: Text(timestamp.toString()),
            );
          }).toList(),
        );
      },
    );
  }
}
