import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/components/eventnotif.dart';
import 'package:zinsa/pages/AlertPage.dart';
import 'package:zinsa/pages/allmessage_page.dart';
import 'package:zinsa/pages/event_register.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/profile_page.dart';

class Events extends StatefulWidget {
  const Events({Key? key});

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  List<Map<String, dynamic>> events = [];
  TextEditingController eventNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? currentUserUniversity;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    checkAndArchivePastEvents();
  }

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
        final eventRef =
            await FirebaseFirestore.instance.collection('Events').add({
          'eventName': eventNameController.text,
          'description': descriptionController.text,
          'startDate': startDate,
          'endDate': endDate,
          'university': currentUserUniversity,
          'userId':currentUser.uid,
        });

        final eventId = eventRef.id; // Get the auto-generated document ID
        await eventRef.update({
          'eventId': eventId
        }); // Update the event document with the event ID
        EventNotificationSender(eventId: eventId);
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
      barrierColor: Color.fromARGB(148, 5, 148, 117),
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(218, 12, 12, 12),
          title: const Text(
            'Add Event',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  fillColor: Colors.white60,
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  labelText: 'description',
                  fillColor: Colors.white60,
                  labelStyle:
                      TextStyle(color: Colors.white), // Change label color
                ),
                style: TextStyle(color: Colors.white),
                controller: descriptionController,
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
                    initialDate: startDate,
                    firstDate: startDate!.toLocal(),
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
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                createEvent();
                Navigator.of(context).pop();
              },
              child: const Text('Create Event',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEventDialog(
      BuildContext context, Map<String, dynamic> event) async {
    print("Editing event: ${event['eventName']}");

    DateTime newStartDate = event['startDate']?.toDate() ?? DateTime.now();
    DateTime newEndDate = event['endDate']?.toDate() ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event: ${event['eventName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Event name (not editable)
              Text('Event Name: ${event['eventName']}'),
              SizedBox(height: 16),
              // DatePicker for start date
              TextButton(
                onPressed: () async {
                  DateTime? pickedStartDate = await showDatePicker(
                    context: context,
                    initialDate: newStartDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedStartDate != null) {
                    setState(() {
                      newStartDate = pickedStartDate;
                    });
                  }
                },
                child: Text(
                    'Start Date: ${DateFormat('yyyy-MM-dd').format(newStartDate)}'),
              ),
              SizedBox(height: 16),
              // DatePicker for end date
              TextButton(
                onPressed: () async {
                  DateTime? pickedEndDate = await showDatePicker(
                    context: context,
                    initialDate: newEndDate,
                    firstDate: newStartDate.toLocal(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedEndDate != null) {
                    setState(() {
                      newEndDate = pickedEndDate;
                    });
                  }
                },
                child: Text(
                    'End Date: ${DateFormat('yyyy-MM-dd').format(newEndDate)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog without saving changes
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the Firestore document with the new dates
                await FirebaseFirestore.instance
                    .collection('Events')
                    .doc(event['eventId'])
                    .update({
                  'startDate': newStartDate,
                  'endDate': newEndDate,
                });
                Navigator.pop(context); // Close the dialog after saving changes
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event updated successfully')));
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshMessages() async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Events(),
        ),
      );
      await Future.delayed(Duration(seconds: 2));
    }
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

    void navigateToAlertPage() {
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
        leading: const Icon(Icons.event),
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: const Text("E V E N T S"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessages,
        child: Padding(
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
                        DateFormat('dd-MM-yy').format(startDate);
                    final formattedEndDate =
                        DateFormat('dd-MM-yy').format(endDate);
        
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                event['eventName'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "description: ${event['description'] ?? "not updated"}",
                                      style: TextStyle(fontSize: 14)),
                                  Text(
                                      'From: $formattedDate to $formattedEndDate',
                                      style: TextStyle(fontSize: 11)),
                                ],
                              ),
                              onTap: () {
                                navigateToEventRegistrationPage(event['eventId']);
                              },
                            ),
                          ),
                          event['userId'] == FirebaseAuth.instance.currentUser?.uid ?
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text("Edit Event"),
                                  onTap: () {
                                    print("Editing event: ${event['eventName']}");
                                    _showEditEventDialog(context, event);
                                    Navigator.pop(
                                        context); // Close the popup menu after selecting "Edit Event"
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text("Delete Event"),
                                  onTap: () {
                                    // Handle delete event
                                    _deleteEvent(event['eventId']);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ):Container()
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 230, 128, 11),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: cNavigationBar(
        onEventPressed: navigateToEventPage,
        onHomeIconPressed: navigateToHomePage,
        onChatPressed: () =>
            navigateToChatPage(FirebaseAuth.instance.currentUser!.uid),
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
        onAlertPressed: navigateToAlertPage,
      ),
    );
  }

  void _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Events')
          .doc(eventId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event deleted successfully')),
      );
      // After deleting the event, you might want to refresh the events list
      // You can call _fetchEvents() or update the events list in the state accordingly
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event')),
      );
    }
  }
}
