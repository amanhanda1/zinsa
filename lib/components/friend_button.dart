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

    final userDoc =
        FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final friendDoc = userDoc.collection('Friends').doc(widget.userId);
    userDoc.collection('Supportings').doc(widget.userId);
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

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .get();
    final currentUsername = userDoc.data()?['username'];

    if (currentUsername == null) {
      return;
    }

    final friendDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('Friends')
        .doc(currentUser.uid);
    final sprtingDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('Supportings')
        .doc(widget.userId);
    final friendData = {
      'friendId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };
    final sprtData = {
      'friendId': widget.userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await friendDoc.set(friendData);
    await sprtingDoc.set(sprtData); // Set supporting data using friend's ID

    setState(() {
      isFriend = true;
    });

    final notificationData = {
      'user':currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'message': '$currentUsername added you as a friend',
      'userId': currentUser.uid,
    };
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('Notifications')
        .add(notificationData);
  }

  Future<void> removeFriend() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc =
        FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final friendDoc = userDoc.collection('Friends').doc(widget.userId);

    final friendUserDoc =
        FirebaseFirestore.instance.collection('Users').doc(widget.userId);
    final currentUserFriendDoc =
        friendUserDoc.collection('Friends').doc(currentUser.uid);

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
          backgroundColor: MaterialStateProperty.all<Color>(
              isFriend ? Colors.red : Colors.blue),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ),
        child: Text(
          isFriend ? 'Remove Support' : 'Add Support',
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }
}
