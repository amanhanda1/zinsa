import 'package:flutter/material.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String? photoUrl;

  const ProfilePhotoWidget({Key? key, this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50.0,
      backgroundImage: photoUrl != null
          ? NetworkImage(photoUrl!)
          : AssetImage('assets/appimages/pp.jpg') as ImageProvider<Object>,
    );
  }
}