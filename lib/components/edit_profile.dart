import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String? _username;
  String? _bio;
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection("Users")
          .doc(_user!.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _username = userData.get('username');
          _bio = userData.get('bio');
          nameController.text = _username ?? '';
          bioController.text = _bio ?? '';
        });
      }
    }
  }

 Future<void> _updateProfile() async {
  if (_user != null) {
    String username = nameController.text.trim();
    String bio = bioController.text.trim();

    // Update only if username or bio is not empty
    if (username.isNotEmpty || bio.isNotEmpty) {
      await FirebaseFirestore.instance.collection("Users").doc(_user!.uid).update({
        'username': username.isNotEmpty ? username : _username,
        'bio': bio.isNotEmpty ? bio : _bio,
      });

      setState(() {
        _username = username.isNotEmpty ? username : _username;
        _bio = bio.isNotEmpty ? bio : _bio;
      });
    }
    
    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(249, 148, 83, 189),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(249, 148, 83, 189),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter Name',
                hintStyle: TextStyle(color: Color.fromARGB(250, 24, 0, 39)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                hintText: 'Enter Bio',
                hintStyle: TextStyle(color: Color.fromARGB(250, 24, 0, 39)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(250, 24, 0, 39),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Save Profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
