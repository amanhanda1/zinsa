import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zinsa/components/supporting_list.dart';

class SupportCountWidget extends StatelessWidget {
  final String viewedUserId; // User ID of the profile being viewed

  const SupportCountWidget({Key? key, required this.viewedUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // If no user is logged in, don't show the support count
      return const SizedBox();
    }

    return FutureBuilder<String?>(
      future: fetchUserProfileUid(viewedUserId), // Fetch UID of the viewed user
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        final viewedUserUid = snapshot.data;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(viewedUserUid)
              .collection('Supportings')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            final supportCount = snapshot.data?.docs.length ?? 0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportListPage(userId: viewedUserId),
                  ),
                );
              },
              child: Text(
                '$supportCount supportings',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> fetchUserProfileUid(String userProfileId) async {
    DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(userProfileId)
        .get();

    if (userProfileSnapshot.exists) {
      Map<String, dynamic>? userData = userProfileSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        return userData['uid'] as String?;
      } else {
        return null; // User data is null
      }
    } else {
      return null; // User profile document does not exist
    }
  }
}
