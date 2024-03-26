import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String? _profilePicUrl;
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
          _profilePicUrl = userData.get('profilePicUrl');
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
    if (_profilePicUrl != null) {
      print('Selecting profile picture...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        PlatformFile file = result.files.first;
        Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(_user!.uid + '.jpg');
        UploadTask uploadTask = storageRef.putData(file.bytes!);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Download URL: $downloadUrl');
        await FirebaseFirestore.instance.collection("Users").doc(_user!.uid).update({
          'profilePicUrl': downloadUrl,
        });
      } else {
        print('No file selected.');
      }
    }
    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 24, 0, 39),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(250, 24, 0, 39),
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
            Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundImage: _profilePicUrl != null
                      ? NetworkImage(_profilePicUrl!)
                      : const AssetImage('assets/appimages/pp.jpg')
                          as ImageProvider,
                ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _profilePicUrl = pickedFile.path;
                        });
                      }
                    },
                    icon: Icon(Icons.add_a_photo),
                  ),
                )
              ],
            ),
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
                primary: const Color.fromARGB(250, 24, 0, 39),
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
