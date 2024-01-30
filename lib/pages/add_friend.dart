import 'package:flutter/material.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/profile_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> getOtherUsersWithSameUniversity() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();

    final currentUserUniversity = userSnapshot['university'] as String?;

    if (currentUserUniversity == null) {
      return []; // No university information for the current user
    }

    // Update the 'lastSeen' field when a user signs in or performs an action
    await updateUserLastSeen();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('university', isEqualTo: currentUserUniversity)
        .get();

    final otherUsers = querySnapshot.docs
        .where((doc) => doc.id != currentUser.email) // Exclude the current user
        .map((doc) => {
              'id': doc.id,
              'status': doc['status'] ?? 'offline',
            })
        .toList();

    return otherUsers;
  }

  Future<void> updateUserLastSeen() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Update the 'lastSeen' field when a user signs in or performs an action
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .set({
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
                    navigateToProfilePage(otherUsers[index]['id']);
                  },
                  child: Card(
                    color: const Color.fromARGB(164, 255, 255,
                        255), // Set the background color to white with some transparency
                    child: ListTile(
                      title: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("Users")
                            .doc(otherUsers[index]['id'])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Loading...");
                          }

                          if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Text("User data not found");
                          }

                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final username =
                              userData['username'] as String? ?? '';
                          final bio = userData['bio'] ?? '';
                          final lastSeen = userData['lastSeen'];

                          // Calculate time difference to determine online/offline status
                          final currentTime = DateTime.now();
                          final difference = currentTime
                              .difference(lastSeen?.toDate() ?? DateTime(0));

                          // Check if the user was seen within the last 5 minutes
                          final isOnline = difference.inMinutes <= 5;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isOnline ? Colors.black : Colors.grey,
                                ),
                              ),
                              Text(
                                'bio: $bio',
                                style: TextStyle(
                                  fontSize: 12.8,
                                  fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                  color: isOnline ? Colors.black : Colors.grey,
                                ),
                              ),
                              if (lastSeen != null)
                                Text(
                                  'Last seen: ${lastSeen.toDate()}',
                                  style: TextStyle(
                                    fontSize: 12.8,
                                    fontFamily:
                                        GoogleFonts.aBeeZee().fontFamily,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: cNavigationBar(
        onHomeIconPressed: navigateToHomePage,
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.email!),
        onlogout: logout,
      ),
    );
  }
}
