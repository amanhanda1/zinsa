import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class MessagesWidget extends StatefulWidget {
  final String userId;

  const MessagesWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _MessagesWidgetState createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final alertsQuery = await FirebaseFirestore.instance
            .collection('Alerts')
            .where('receiverId', isEqualTo: currentUser.email)
            .orderBy('timestamp', descending: true)
            .get();

        for (final alertDoc in alertsQuery.docs) {
          final senderId = alertDoc['senderId'] as String;
          final message = alertDoc['message'] as String;

          // Display the alert and provide options
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Alert from $senderId'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Send the alert back
                    await FirebaseFirestore.instance.collection('Alerts').add({
                      'senderId': currentUser.email,
                      'receiverId': senderId,
                      'message': 'Alert response: $message',
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Send Alert Back'),
                ),
                TextButton(
                  onPressed: () {
                    // Open the message page
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagesWidget(userId: senderId),
                      ),
                    );
                  },
                  child: Text('Send Message'),
                ),
              ],
            ),
          );
        }
      }
    } catch (error) {
      print("Error fetching alerts: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Messages')
                  .where('senderId',
                      whereIn: [FirebaseAuth.instance.currentUser!.email, widget.userId])
                  .where('receiverId',
                      whereIn: [FirebaseAuth.instance.currentUser!.email, widget.userId])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final senderId = messageData['senderId'] as String;
                    final text = messageData['text'] as String;

                    final isCurrentUser = senderId == FirebaseAuth.instance.currentUser!.email;

                    return ListTile(
                      title: Text(text),
                      tileColor: isCurrentUser ? Colors.blue : Colors.grey,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.black),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage();
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final text = _messageController.text.trim();

      if (text.isNotEmpty) {
        await FirebaseFirestore.instance.collection('Messages').add({
          'senderId': currentUser.email,
          'receiverId': widget.userId,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _messageController.clear();
      }
    }
  }
}