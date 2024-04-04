import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/messaging/chatroom.dart';
import 'package:zinsa/pages/add_alerts.dart';
import 'package:zinsa/pages/add_friend.dart';
import 'package:zinsa/pages/allmessage_page.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/ongoing_events.dart';
import 'package:zinsa/pages/profile_page.dart';

class Stories extends StatefulWidget {
  const Stories({Key? key}) : super(key: key);

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
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

    void navigateToAddFriendPage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFriendPage(),
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

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        leading: const Icon(Icons.add_alert),
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: const Text("Alerts"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData) {
            return Center(child: Text("User data not found"));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final currentUserUniversity = userData['university'] as String?;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Alerts').where('university', isEqualTo: currentUserUniversity).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final alerts = snapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index].data() as Map<String, dynamic>;
                  final userId = alert['userId'] as String;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (userSnapshot.hasError || !userSnapshot.hasData) {
                        return Container();
                      }

                      final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white.withOpacity(0.42),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            alert['text'] ?? '',
                            style: TextStyle(
                              fontFamily: GoogleFonts.nunito().fontFamily,
                              fontSize: 21,
                              fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'alerted by: ${userData['username'] ?? 'Unknown User'}',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 39, 38, 38))),
                              Text(
                                'enquire',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.cardo().fontFamily,
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 39, 38, 38))),
                              const SizedBox(height: 2),
                              Text(
                                _formatDateTime(alert['timestamp'] as Timestamp? ?? Timestamp.now()),
                                style: TextStyle(
                                  fontFamily: GoogleFonts.lobster().fontFamily,
                                  fontSize: 9.8,
                                  color: const Color.fromARGB(255, 39, 38, 38))),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomPage(
                                  senderUserId:
                                      currentUser.uid, // Current user ID
                                  receiverUserId:
                                      userId, // Profile user ID
                                ),
                              ),
                            );
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
    
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAlertsPage(),
            ),
          );
        },
        autofocus: true,
        backgroundColor: const Color.fromARGB(255, 230, 128, 11),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: cNavigationBar(
        onEventPressed: navigateToEventPage,
        onHomeIconPressed: navigateToHomePage,
        onChatPressed: ()=>navigateToChatPage(FirebaseAuth.instance.currentUser!.uid),
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
        onAlertPressed: () {},
      ),
    );
  }

  String _formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    if (dateTime == null) {
      return 'Unknown Date and Time';
    }
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _deleteOldAlerts(); // Start deleting old alerts when the page is initialized
  }

  Future<void> _deleteOldAlerts() async {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(Duration(hours: 24));

    // Query alerts older than 24 hours
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Alerts')
        .where('timestamp', isLessThan: twentyFourHoursAgo)
        .get();

    // Delete each alert
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
