import 'dart:io' show File, Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final String? photoUrl;
  final String userId;

  const ProfilePhotoWidget({Key? key, this.photoUrl, required this.userId})
      : super(key: key);

  @override
  _ProfilePhotoWidgetState createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  File? _imageFile;

  Future<void> _pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        setState(() {
          _imageFile = File(result.files.single.path!);
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');
        await storageRef.putFile(_imageFile!);

        final downloadUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'photoUrl': downloadUrl});
            } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  void _showOptionsDialog() {
    final isCurrentUser =
        FirebaseAuth.instance.currentUser?.uid == widget.userId;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an option"),
          actions: <Widget>[
            if (isCurrentUser)
              TextButton(
                child: Text("Edit Photo"),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage().then((_) {
                    _uploadImage();
                  });
                },
              ),
            TextButton(
              child: Text(
                "View Expanded",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context);
                _showExpandedPhoto();
              },
            ),
          ],
        );
      },
    );
  }

  void _showExpandedPhoto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider<Object>
                    : NetworkImage(widget.photoUrl!) as ImageProvider<Object>,
                fit: BoxFit.cover,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showOptionsDialog();
      },
      child: ClipOval(
        child: _imageFile != null
            ? Image.file(_imageFile!,
                width: 100, height: 100, fit: BoxFit.cover)
            : widget.photoUrl != null
                ? Image.network(widget.photoUrl!,
                    width: 100, height: 100, fit: BoxFit.cover)
                : Image.asset('assets/appimages/pp.jpg',
                    width: 100, height: 100, fit: BoxFit.cover),
      ),
    );
  }
}
