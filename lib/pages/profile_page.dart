import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zinsa/components/Friends_count.dart';
import 'package:zinsa/components/Support_count.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/components/edit_profile.dart';
import 'package:zinsa/components/friend_button.dart';
import 'package:zinsa/components/hobbies.dart';
import 'package:zinsa/components/postwid.dart';
import 'package:zinsa/components/profile_photo.dart';
import 'package:zinsa/messaging/chatroom.dart';
import 'package:zinsa/pages/AlertPage.dart';
import 'package:zinsa/pages/allmessage_page.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/notif_page.dart';
import 'package:zinsa/pages/ongoing_events.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showPosts = true;
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

    void navigateToNotificationPage(BuildContext context) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationPage(userId: currentUser.uid),
          ),
        );
      }
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

    Future<void> _refreshMessages(userId) async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: userId),
        ),
      );
      await Future.delayed(Duration(seconds: 2));
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnProfile = widget.userId == currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        leading: const Icon(Icons.person_outlined),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("ZINSA")],
        ),
        actions: isOwnProfile?[
          // Add PopupMenuButton
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                logout();
              } else if (value == 'notifications') {
                navigateToNotificationPage(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              // Option 1: Logout
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
              // Option 2: Navigate to NotificationPage
              const PopupMenuItem<String>(
                value: 'notifications',
                child: ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notifications'),
                ),
              ),
            ],
          ),
        ]:null,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            _refreshMessages(FirebaseAuth.instance.currentUser!.uid),
        child: FutureBuilder<DocumentSnapshot>(
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
                  Container(
                    width: 100, // Adjust width as needed
                    height: 100, // Adjust height as needed
                    child: ProfilePhotoWidget(
                      photoUrl: photoUrl.isNotEmpty ? photoUrl : null,
                      userId: widget.userId,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Name: $name ",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: GoogleFonts.aBeeZee().fontFamily,
                        ),
                      ),
                      if (dob != null) ...[
                        Text(
                          "{${calculateAge(dob)}}",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.aBeeZee().fontFamily,
                          ),
                        ),
                        if (!isOwnProfile) ...[
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                    senderUserId:
                                        currentUser!.uid, // Current user ID
                                    receiverUserId:
                                        widget.userId, // Profile user ID
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble,
                                color: Colors.white),
                          ),
                        ],
                      ],
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
                            builder: (context) => EditProfileScreen(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.orange.shade800,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side:
                                BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255)),
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
                      Spacer(),
                      SupportCountWidget(viewedUserId: widget.userId),
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
                            FirebaseAuth.instance.currentUser!.uid),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
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
