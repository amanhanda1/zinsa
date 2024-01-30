import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendListPage extends StatelessWidget {
  final String userId;

  const FriendListPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: Text('Friends List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Friends')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          final friends = snapshot.data?.docs ?? [];

          if (friends.isEmpty) {
            return const Center(
              child: Text('No friends yet.'),
            );
          }

          return FutureBuilder<List<String>>(
            // Fetch usernames based on friend email addresses
            future: fetchUsernames(friends),
            builder: (context, usernamesSnapshot) {
              if (usernamesSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (usernamesSnapshot.hasError) {
                return Text("Error: ${usernamesSnapshot.error}");
              }

              final usernames = usernamesSnapshot.data ?? [];

              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friendEmail = friends[index].id;
                  final friendUsername = usernames[index];
                  return ListTile(
                    title: Text(friendUsername),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to fetch usernames based on email addresses
  Future<List<String>> fetchUsernames(List<QueryDocumentSnapshot<Object?>> friends) async {
    final List<String> usernames = [];

    for (final friend in friends) {
      final friendEmail = friend.id;
      final userData = await FirebaseFirestore.instance.collection('Users').doc(friendEmail).get();

      if (userData.exists) {
        final username = userData['username'] as String;
        usernames.add(username);
      } else {
        // If user data not found, you can handle it accordingly
        usernames.add('Unknown User');
      }
    }

    return usernames;
  }
}