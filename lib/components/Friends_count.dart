import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zinsa/components/friend_list.dart';

class FriendCountWidget extends StatelessWidget {
  final String userId;

  const FriendCountWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && userId == currentUser.email) {
      // If it's the user's own profile, don't show the friend count
      return const SizedBox();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Friends')
          .snapshots(),
      builder: (context, snapshot) {
        print('Friend Count StreamBuilder executed');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        final friendCount = snapshot.data?.docs.length ?? 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendListPage(userId: userId),
              ),
            );
          },
          child: Text(
            '$friendCount supporters',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}
