import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendButton extends StatefulWidget {
  final String userId;

  const FriendButton({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendButtonState createState() => _FriendButtonState();
}
class _FriendButtonState extends State<FriendButton> {
  late bool isFriend;

  @override
  void initState() {
    super.initState();
    isFriend = false; // Initialize with a default value
    checkFriendStatus();
  }

  Future<void> checkFriendStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
    final friendDoc = userDoc.collection('Friends').doc(widget.userId);

    final friendSnapshot = await friendDoc.get();

    setState(() {
      isFriend = friendSnapshot.exists;
    });
  }

  Future<void> addFriend() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return;
  }

  final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
  final friendDoc = userDoc.collection('Friends').doc(widget.userId);

  // Create a regular Map with the desired data
  final friendData = {
    'friendId': widget.userId,
    'timestamp': FieldValue.serverTimestamp(),
  };

  // Add the friend data to Firestore
  await friendDoc.set(friendData);

  // Update friend list for the user you're adding
  final friendUserDoc = FirebaseFirestore.instance.collection('Users').doc(widget.userId);
  final currentUserFriendDoc = friendUserDoc.collection('Friends').doc(currentUser.email);

  final currentUserData = {
    'friendId': currentUser.email,
    'timestamp': FieldValue.serverTimestamp(),
  };

  await currentUserFriendDoc.set(currentUserData);

  setState(() {
    isFriend = true;
  });
}
  Future<void> removeFriend() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.email);
    final friendDoc = userDoc.collection('Friends').doc(widget.userId);

    final friendUserDoc = FirebaseFirestore.instance.collection('Users').doc(widget.userId);
    final currentUserFriendDoc = friendUserDoc.collection('Friends').doc(currentUser.email);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.delete(friendDoc);
        await transaction.delete(currentUserFriendDoc);
      });
    } catch (e) {
      print('Error removing friend: $e');
    }

    setState(() {
      isFriend = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ElevatedButton(
        onPressed: isFriend ? removeFriend : addFriend,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(isFriend ? Colors.red : Colors.blue),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ),
        child: Text(
          isFriend ? 'Remove Friend' : 'Add Friend',
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }
}