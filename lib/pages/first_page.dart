import 'package:flutter/material.dart';
import 'package:zinsa/components/showuniversities.dart';
import 'package:zinsa/pages/add_friend.dart';
import 'package:zinsa/pages/home_page.dart';
import 'package:zinsa/pages/login_page.dart';
import 'package:zinsa/pages/profile_page.dart';
import 'package:zinsa/pages/sign_up_page.dart';
import 'package:zinsa/pages/AlertPage.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Create a Tween animation for zooming out
    _animation = Tween<double>(
      begin: 0.2, // Initial scale factor (you can adjust this based on your preference)
      end: 1.0, // Final scale factor
    ).animate(_animationController);

    // Start the animation
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Z I N S A",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToLoginPage(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all(const Size(999, 44)),
                ),
                child: Text(
                  "L O G I N",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  _navigateToSignUpPage(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all(const Size(999, 44)),
                ),
                child: Text(
                  "N E W  U S E R ?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostPage()),
    );
  }

  void _navigateToSignUpPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  RegisterPage()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
