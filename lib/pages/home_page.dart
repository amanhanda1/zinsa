import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zinsa/components/custom_nav_bar.dart';
import 'package:zinsa/pages/AlertPage.dart';
import 'package:zinsa/pages/add_friend.dart';
import 'package:zinsa/pages/add_post.dart';
import 'package:zinsa/pages/allmessage_page.dart';
import 'package:zinsa/pages/first_page.dart';
import 'package:zinsa/pages/ongoing_events.dart';
import 'package:zinsa/pages/profile_page.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key});

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshMessages() async {
      Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PostPage(),),
          );
      await Future.delayed(Duration(seconds: 2));
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
    void navigateToAlertPage(){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Stories(),
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

    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: const Text("P O S T S"),
        actions: [
          // Add an icon button to navigate to the AddFriendPage
          IconButton(
            onPressed: navigateToAddFriendPage,
            icon: Icon(Icons.person_add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessages,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
        
            final posts = snapshot.data?.docs ?? [];
        
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                final userId = post['userId'] as String;
        
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
        
                    if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return Container();
                    }
        
                    final userData =
                        userSnapshot.data?.data() as Map<String, dynamic>?;
        
                    return Card(
                      elevation: 5,
                      margin:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          post['text'] ?? '',
                          style: TextStyle(
                              fontFamily: GoogleFonts.nunito().fontFamily,
                              fontSize: 21,
                              fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Posted by: ${userData?['username'] ?? 'Unknown User'}',
                                style: TextStyle(
                                    fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                    fontSize: 12,
                                    color:
                                        const Color.fromARGB(255, 39, 38, 38))),
                            Text(
                                '${userData?['university'] ?? 'Unknown University'}',
                                style: TextStyle(
                                    fontFamily: GoogleFonts.cardo().fontFamily,
                                    fontSize: 12,
                                    color:
                                        const Color.fromARGB(255, 39, 38, 38))),
                            const SizedBox(height: 2),
                            Text(
                                _formatDateTime(post['timestamp'] as Timestamp? ??
                                    Timestamp.now()),
                                style: TextStyle(
                                    fontFamily: GoogleFonts.lobster().fontFamily,
                                    fontSize: 9.8,
                                    color:
                                        const Color.fromARGB(255, 39, 38, 38))),
                          ],
                        ),
                        onTap: () {
                          navigateToProfilePage(userId);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostPage(),
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
        onChatPressed: ()=>navigateToChatPage(FirebaseAuth.instance.currentUser!.uid!),
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid!),
        onAlertPressed: navigateToAlertPage,
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
}
