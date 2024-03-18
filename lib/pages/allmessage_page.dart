import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' show AppBar, AsyncSnapshot, BuildContext, Center, CircularProgressIndicator, Color, ConnectionState, Container, Icon, Icons, Key, ListTile, ListView, MainAxisAlignment, MaterialPageRoute, Navigator, Row, Scaffold, StatelessWidget, StreamBuilder, Text, Widget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/messaging/chatroom.dart';
import 'package:zinsa/pages/AlertPage.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/ongoing_events.dart';
import 'package:zinsa/pages/profile_page.dart';

class allMessages extends StatelessWidget {
  final String userId;

  const allMessages({Key? key, required this.userId}) : super(key: key);

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
        leading: const Icon(Icons.person_outlined),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("ZINSA")],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Conversations')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No conversations yet.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String conversationId = doc['conversationId'];
              String senderId = doc['senderUserId'];
              String receiverId = doc['receiverUserId'];
              String otherUserId = senderId == currentUser!.uid ? receiverId : senderId;
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(otherUserId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Placeholder until data is loaded
                  }
                  if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  }
                  if (!userSnapshot.hasData) {
                    return Container(); // Placeholder for empty user data
                  }
                  String otherUserName = userSnapshot.data!['username'];
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Conversations')
                        .doc(conversationId)
                        .collection('Messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                      if (messageSnapshot.connectionState == ConnectionState.waiting) {
                        return Container(); // Placeholder until data is loaded
                      }
                      if (messageSnapshot.hasError) {
                        return Text('Error: ${messageSnapshot.error}');
                      }
                      if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                        return Container(); // Placeholder for empty chat
                      }
                      String lastMessage = messageSnapshot.data!.docs.first['message'];
                      return ListTile(
                        title: Text(otherUserName),
                        subtitle: Text(lastMessage),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomPage(senderUserId: currentUser.uid, receiverUserId: otherUserId),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: cNavigationBar(
        onEventPressed: navigateToEventPage,
        onHomeIconPressed: navigateToHomePage,
        onChatPressed: () =>{},
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid!),
        onAlertPressed: navigateToAlertPage,
      ),
    );
  }
}
