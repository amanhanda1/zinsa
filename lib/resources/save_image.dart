import 'dart:js';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    String? name,
    String? bio,
    Uint8List? file,
  }) async {
    String resp = " Some Error Occurred";
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        _firestore.collection('Users').doc(currentUser.uid).set({ 
          'bio': '', // Initial bio
          'imageLink': '', // Initial imageLink
        });

        if (name!.isNotEmpty || bio!.isNotEmpty) {
          String imageUrl = await uploadImageToStorage('profileImage', file!);

          // Get the reference to the user's document
          DocumentReference userRef = _firestore.collection('Users').doc(currentUser.email);

          // Update the values in the existing document
          await userRef.update({
            'username': name,
            'bio': bio,
            'imageLink': imageUrl,
          });
          

          resp = 'success';
        }
      } else {
        resp = 'User not logged in';
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}


