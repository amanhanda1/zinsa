import 'package:flutter/material.dart';

class cNavigationBar extends StatelessWidget {
  final VoidCallback onProfileIconPressed;
  final VoidCallback onHomeIconPressed;
  final VoidCallback onEventPressed;
  final VoidCallback onChatPressed;
  final VoidCallback onAlertPressed;
  cNavigationBar({
    required this.onProfileIconPressed,
    required this.onHomeIconPressed,
    required this.onEventPressed,
    required this.onChatPressed,
    required this.onAlertPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 200,
      color: const Color.fromARGB(206, 29, 110, 92),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround, // Adjusted to evenly space icons
        mainAxisSize: MainAxisSize.min, // Adjusted to center icons vertically
        children: [
          IconButton(
            icon: const Icon(Icons.home_filled),
            onPressed: onHomeIconPressed,
          ),
          IconButton(onPressed: onEventPressed, icon: Icon(Icons.event)),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: onProfileIconPressed,
          ),
          IconButton(
            onPressed: onChatPressed,
            icon: Icon(Icons.message_outlined),
          ),
          
          IconButton(
            onPressed: onAlertPressed,
            icon: Icon(Icons.add_alert_rounded),
          ),
          
        ],
      ),
    );
  }
}
