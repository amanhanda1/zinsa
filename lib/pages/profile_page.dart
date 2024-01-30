import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/components/edit_profile.dart';
import 'package:zinsa/components/friend_button.dart';
import 'package:zinsa/components/friend_count%5Bel%5D.dart';
import 'package:zinsa/components/hobbies.dart';
import 'package:zinsa/components/postwid.dart';
import 'package:zinsa/components/show_profile.dart';
import 'package:zinsa/components/alert_box.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/message_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showPosts = true;
  bool showMessages = false; // Add this line

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

    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnProfile = widget.userId == currentUser?.email;

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.userId)
            .get(),
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

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("User data not found"),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['username'] ?? '';
          final dob = userData['dob'] as Timestamp?;
          final bio = userData['bio'] ?? '';
          final universityName = userData['university'] ?? '';
          final photoUrl = userData['photoUrl'] ?? '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(child: Text("P R O F I L E")),
                const SizedBox(height: 18),
                ProfilePhotoWidget(photoUrl: photoUrl),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Name: $name ",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.aBeeZee().fontFamily)),
                    if (dob != null)
                      Text("{${calculateAge(dob)}}",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: GoogleFonts.aBeeZee().fontFamily)),
                    if (!isOwnProfile)
                      IconButton(
                        onPressed: () {
                          // Show Send Alert Dialog
                          showDialog(
                            context: context,
                            builder: (context) => SendAlertDialog(
                              onAlertSent: (message) async {
                                // Handle the alert message (e.g., save it to Firestore)
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                if (currentUser != null) {
                                  await FirebaseFirestore.instance
                                      .collection('Alerts')
                                      .add({
                                    'senderId': currentUser.email,
                                    'receiverId': widget.userId,
                                    'message': message,
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });
                                }
                              },
                              userId: widget
                                  .userId, // Pass the user ID from ProfilePage
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.message_outlined,
                          color: Colors
                              .white, // Keep it white or change to Colors.orange
                          size: 18, // You can adjust the size as needed
                        ),
                      )
                  ],
                ),
                Text(universityName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: GoogleFonts.josefinSans().fontFamily)),
                const SizedBox(height: 8),
                if (isOwnProfile)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.orange.shade800,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  )
                else
                  FriendButton(userId: widget.userId),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "$bio",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: Colors.orange,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FriendCountWidget(userId: widget.userId),
                  ],
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showPosts = !showPosts;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.orange.shade800,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                  // Use a conditional expression to set the child property based on isOwnProfile
                  child: Text(
                    isOwnProfile
                        ? (showPosts ? 'Add Hobbies' : 'Edit Posts')
                        : (showPosts ? 'Show Hobbies' : 'Show Posts'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                if (showPosts)
                  PostsWidget(userId: widget.userId)
                else
                  HobbiesWidget(
                      userId: widget.userId,
                      isOwnProfile: widget.userId ==
                          FirebaseAuth.instance.currentUser!.email),
                const SizedBox(height: 8),
                if (showMessages) MessagesWidget(userId: widget.userId),
              ],
            ),
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

  int? calculateAge(Timestamp? dob) {
    if (dob == null) {
      return null;
    }

    final currentDate = DateTime.now();
    final age = currentDate.year -
        dob.toDate().year -
        (currentDate.month > dob.toDate().month ||
                (currentDate.month == dob.toDate().month &&
                    currentDate.day >= dob.toDate().day)
            ? 0
            : 1);
    return age;
  }
}
