import 'package:flutter/material.dart';
import 'dart:async';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/pages/AlertPage.dart';
import 'package:zinsa/pages/allmessage_page.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/ongoing_events.dart';
import 'package:zinsa/pages/profile_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/ongoing_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  late Timer _timer;
  late Map<String, dynamic> _userDataCache = {};
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      updateLastSeen();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<List<String>> getOtherUsersWithSameUniversity() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .get();

    final currentUserUniversity = userSnapshot['university'] as String?;

    if (currentUserUniversity == null) {
      return []; 
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('university', isEqualTo: currentUserUniversity)
        .get();

    final otherUsers = querySnapshot.docs
        .where((doc) => doc.id != currentUser.uid)
        .map((doc) => doc.id)
        .toList();

    return otherUsers;
  }

  bool _checkOnlineStatus(dynamic lastSeen) {
    if (lastSeen is Timestamp) {
      final currentTime = Timestamp.now();
      final difference = currentTime.seconds - lastSeen.seconds;
      return difference < 300;
    }
    return false;
  }

  void updateLastSeen() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .update({'lastseen': FieldValue.serverTimestamp()});
    }
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    if (_userDataCache.containsKey(userId)) {
      return _userDataCache[userId]!;
    } else {
      final snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        _userDataCache[userId] = userData;
        return userData;
      } else {
        return {};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void logout() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FirstPage(),
        ),
      );
    }

    void navigateToUniversityListScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFriendPage(),
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
          builder: (context) => PostPage(),
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("ZINSA")],
        ),
        elevation: 1000,
      ),
      body: FutureBuilder<List<String>>(
        future: getOtherUsersWithSameUniversity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final otherUsers = snapshot.data ?? [];

          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.2),
                child: GestureDetector(
                  onTap: () {
                    navigateToProfilePage(otherUsers[index]);
                  },
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: getUserData(otherUsers[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading...");
                      }

                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text("User data not found");
                      }

                      final userData = snapshot.data!;
                      final username = userData['username'] as String? ?? '';
                      final bio = userData['bio'] ?? '';
                      final lastSeen = userData['lastseen'];

                      final isOnline = _checkOnlineStatus(lastSeen);

                      final cardColor = isOnline
                          ? Color.fromARGB(255, 250, 253,251) 
                          : Color.fromARGB(72, 252, 252,252); 
                      final dotColor = isOnline ? Colors.green : Colors.red;

                      return Card(
                        color: cardColor,
                        child: ListTile(
                          leading: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(username,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              Text('bio: $bio',
                                  style: TextStyle(
                                      fontSize: 12.8,
                                      fontFamily:
                                          GoogleFonts.aBeeZee().fontFamily)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
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

