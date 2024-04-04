import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/components/profile_photo.dart';
import 'package:zinsa/messaging/chatroom.dart';
import 'package:zinsa/pages/AlertPage.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/ongoing_events.dart';
import 'package:zinsa/pages/profile_page.dart';

class allMessages extends StatefulWidget {
  final String userId;

  const allMessages({Key? key, required this.userId}) : super(key: key);

  @override
  _allMessagesState createState() => _allMessagesState();
}

class _allMessagesState extends State<allMessages> {
  @override
  Widget build(BuildContext context) {
    void navigateToHomePage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PostPage(),
        ),
      );
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

    void navigateToEventPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Events(),
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
          builder: (context) => const Stories(),
        ),
      );
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        leading: const Icon(Icons.message_outlined),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("ZINSA")],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.userId)
                  .collection('Conversations')
                  .snapshots(),
              builder:
                  (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No conversations yet.'));
                }
                return ListView.builder(
                  reverse: true, // Display items in reverse order
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    String conversationId = doc['conversationId'];
                    String senderId = doc['senderUserId'];
                    String receiverId = doc['receiverUserId'];
                    String otherUserId =
                        senderId == currentUser!.uid ? receiverId : senderId;
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(otherUserId)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(); // Placeholder until data is loaded
                        }
                        if (userSnapshot.hasError) {
                          return Text('Error: ${userSnapshot.error}');
                        }
                        if (!userSnapshot.hasData) {
                          return Container(); // Placeholder for empty user data
                        }
                        String otherUserName = userSnapshot.data!['username'];
                        Map<String, dynamic>? userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;
                        String? photoUrl = userData!.containsKey('photoUrl')
                            ? userData['photoUrl']
                            : null;
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Conversations')
                              .doc(conversationId)
                              .collection('Messages')
                              .orderBy('timestamp', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                            if (messageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(); // Placeholder until data is loaded
                            }
                            if (messageSnapshot.hasError) {
                              return Text('Error: ${messageSnapshot.error}');
                            }
                            if (!messageSnapshot.hasData ||
                                messageSnapshot.data!.docs.isEmpty) {
                              return Container(); // Placeholder for empty chat
                            }
                            String lastMessage =
                                messageSnapshot.data!.docs.first['message'];
                            bool hasNewMessage =
                                messageSnapshot.data!.docs.first['senderUserId'] !=
                                    currentUser.uid;
                            bool isMessageSeen =
                                messageSnapshot.data!.docs.first['seen'] ?? false;
                            bool showNewMessageIndicator =
                                hasNewMessage && !isMessageSeen; // Updated condition
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey.shade300,
                                  child: ProfilePhotoWidget(
                                    photoUrl: photoUrl,
                                    userId: otherUserId,
                                  ),
                                ),
                                title: Text(
                                  otherUserName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  lastMessage,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: showNewMessageIndicator
                                        ? Colors.blue
                                        : null,
                                  ),
                                ),
                                trailing: hasNewMessage && !isMessageSeen
                                    ? CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        radius: 8.0,
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                          senderUserId: currentUser.uid,
                                          receiverUserId: otherUserId),
                                    ),
                                  );
                                  FirebaseFirestore.instance
                                    .collection('Conversations')
                                    .doc(conversationId)
                                    .collection('Messages')
                                    .doc(messageSnapshot.data!.docs.first.id)
                                    .update({'seen': true});
                                },
                              ),
                            );
                            
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10), // Add some space between the list and the bottom navigation bar
        ],
      ),
      bottomNavigationBar: cNavigationBar(
        onEventPressed: navigateToEventPage,
        onHomeIconPressed: navigateToHomePage,
        onChatPressed: () => {},
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
        onAlertPressed: navigateToAlertPage,
      ),
    );
  }
}
