import 'package:flutter/material.dart';
class cNavigationBar extends StatelessWidget {
  
  final VoidCallback onProfileIconPressed;
  final VoidCallback onlogout;
  final VoidCallback onHomeIconPressed;

  cNavigationBar({
   
    required this.onProfileIconPressed,
    required this.onlogout,
    required this.onHomeIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    
    return BottomAppBar(
      elevation: 200,
      color: const Color.fromARGB(206, 29, 110, 92),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjusted to evenly space icons
        mainAxisSize: MainAxisSize.min, // Adjusted to center icons vertically
        children: [
          IconButton(
            icon: const Icon(Icons.home_filled),
            onPressed: onHomeIconPressed,
          ),
          
          
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: onProfileIconPressed,
          ),
          IconButton(onPressed: onlogout, icon: Icon(Icons.logout_rounded))
        ],
      ),
    );
  }
}
