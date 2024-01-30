import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zinsa/pages/message_page.dart';

class SendAlertDialog extends StatelessWidget {
  final Function(String) onAlertSent;
  final String userId; // Add this line

  const SendAlertDialog({Key? key, required this.onAlertSent, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = TextEditingController();

    return AlertDialog(
      title: const Text('Send Alert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Type your alert message:'),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Your message here...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () {
            String message = _messageController.text.trim();
            onAlertSent(message);

            // Open the message page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessagesWidget(userId: userId), // Pass userId here
              ),
            );
          },
          child: const Text('Send', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}