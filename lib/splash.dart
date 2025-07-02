import 'package:flutter/material.dart';
import 'package:obulamucare/login_screen.dart';

// Make sure that register_screen.dart defines a class named RegisterScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Optional: match the style
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/images/eye.png', height: 200, width: 200),
            SizedBox(height: 10),
            // Text
            Text(
              'OBULAMU CARE',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.orange,
                fontFamily:
                    'Montserrat', // Ensure you have this font in your pubspec.yaml
                // You can adjust color
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Loading......",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 18),
                ),
                const SizedBox(width: 10),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  strokeWidth: 2.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}