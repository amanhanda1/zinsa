import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/pages/AlertPage.dart';
import 'package:zinsa/pages/allmessage_page.dart';
import 'package:zinsa/pages/event_register.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/profile_page.dart';
import 'package:intl/intl.dart';

class Events extends StatefulWidget {
  const Events({Key? key});

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  List<Map<String, dynamic>> events = [];
  TextEditingController eventNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? currentUserUniversity;
  int count=0;

  Future<void> createEvent() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .get();

    final dynamic universityData = userSnapshot['university'];
    currentUserUniversity =
        universityData != null ? universityData as String : null;

    if (startDate != null &&
        endDate != null &&
        currentUserUniversity != null &&
        eventNameController.text.isNotEmpty) {
      final eventRef = await FirebaseFirestore.instance.collection('Events').add({
        'eventName': eventNameController.text,
        'startDate': startDate,
        'endDate': endDate,
        'university': currentUserUniversity,
      });

      final eventId = eventRef.id; // Get the auto-generated document ID
      await eventRef.update({'eventId': eventId}); // Update the event document with the event ID

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully')),
      );
    } else {
      print(
          'Please select both start and end dates, ensure university is set, and provide a non-empty event name.');
    }
  } catch (e) {
    print('Error creating event: $e');
  }
}


  Future<void> checkAndArchivePastEvents() async {
    final now = DateTime.now();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .get();
    final currentUserUniversity = userSnapshot['university'] as String?;

    final pastEvents = await FirebaseFirestore.instance
        .collection('Events')
        .where('university', isEqualTo: currentUserUniversity)
        .where('endDate', isLessThan: now)
        .get();

    for (var event in pastEvents.docs) {
      await FirebaseFirestore.instance
          .collection('ArchivedEvents')
          .add(event.data());
      await FirebaseFirestore.instance
          .collection('Events')
          .doc(event.id)
          .delete();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .get();

      final universityData = userSnapshot['university'];
      if (universityData != null) {
        if (universityData is String) {
          // It's of type String, so we can safely assign it
          currentUserUniversity = universityData;
        } else {
          print('Error: University data is not a String');
        }
      } else {
        print('Error: University data is null or does not exist');
      }

      if (currentUserUniversity != null) {
        final eventDocs = await FirebaseFirestore.instance
            .collection('Events')
            .where('university', isEqualTo: currentUserUniversity)
            .get();

        setState(() {
          events = eventDocs.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        // Handle the case where currentUserUniversity is null
        print('Current user university is null.');
      }
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedStartDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );

                  if (pickedStartDate != null) {
                    setState(() {
                      startDate = pickedStartDate;
                    });
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.orange.shade800,
                  ),
                ),
                child: Text(
                  startDate != null
                      ? 'Start Date: ${startDate!.toLocal()}'
                      : 'Select Start Date',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedEndDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );

                  if (pickedEndDate != null) {
                    setState(() {
                      endDate = pickedEndDate;
                    });
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.orange.shade800,
                  ),
                ),
                child: Text(
                  endDate != null
                      ? 'End Date: ${endDate!.toLocal()}'
                      : 'Select End Date',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                createEvent();
                Navigator.of(context).pop();
              },
              child: const Text('Create Event',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void logout() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FirstPage(),
        ),
      );
    }

    void navigateToProfilePage(String userId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: userId),
        ),
      );
    }

    void navigateToHomePage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PostPage(),
        ),
      );
    }

    void navigateToEventPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Events(),
        ),
      );
    }

    void navigateToEventRegistrationPage(String eventId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventsRegistrationPage(eventId: eventId),
        ),
      );
    }
    void navigateToChatPage(String userId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => allMessages(userId: userId),
        ),
      );
    }
    void navigateToAlertPage(){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Stories(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: const Text("E V E N T S"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: events.isEmpty
            ? const Center(child: Text('Waiting for the events'))
            : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final startDate = event['startDate']?.toDate();
                  final endDate = event['endDate']?.toDate();

                  if (startDate == null || endDate == null) {
                    return SizedBox(); // Placeholder widget or handle the case of missing date data
                  }

                  final formattedDate =
                      DateFormat('yyyy-MM-dd').format(startDate);
                  final formattedEndDate =
                      DateFormat('yyyy-MM-dd').format(endDate);

                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      title: Text(event['eventName'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: $formattedDate to $formattedEndDate'),
                          SizedBox(height: 4),
                        ],
                      ),
                      onTap: () {
                        navigateToEventRegistrationPage(event['eventId']);
                      },
                      onLongPress: () {
                        final String contentToCopy =
                            '${event['eventName']}\nFrom: $formattedDate to $formattedEndDate\nEvent ID: ${event['eventId']}';
                        Clipboard.setData(ClipboardData(text: contentToCopy));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Content copied to clipboard')),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: cNavigationBar(
        onEventPressed: navigateToEventPage,
        onHomeIconPressed: navigateToHomePage,
        onChatPressed: () =>navigateToChatPage(FirebaseAuth.instance.currentUser!.uid!),
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid!),
        onAlertPressed: navigateToAlertPage,
      ),
    
  
    );
  }
}
