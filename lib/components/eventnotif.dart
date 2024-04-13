import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventNotificationSender extends StatelessWidget {
  final String eventId;

  const EventNotificationSender({Key? key, required this.eventId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle case where user is not logged in
      return SizedBox.shrink();
    }

    // Get the supporting document
    final supportingDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('Supportings')
        .doc(currentUser.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: supportingDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }
        if (snapshot.hasError) {
          // Handle error
          return SizedBox.shrink();
        }
        final supportingData = snapshot.data?.data() as Map<String, dynamic>?;

        if (supportingData == null) {
          // Handle case where supporting data is not available
          return SizedBox.shrink();
        }

        final isSupporting = supportingData["isSupporting"] ?? false;

        // If user is supporting, send notification
        if (isSupporting) {
          sendNotification(currentUser.uid, eventId);
        }

        return SizedBox.shrink();
      },
    );
  }

  Future<void> sendNotification(String userId, String eventId) async {
    try {
      final notificationData = {
        'message': 'A new event has been created!',
        'eventId': eventId,
        'timestamp': Timestamp.now(),
        // Add any other relevant data to the notification
      };

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Notifications')
          .add(notificationData);
    } catch (e) {
      // Handle error
      print('Error sending notification: $e');
    }
  }
}
