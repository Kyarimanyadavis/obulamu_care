import 'dart:ui'; // For ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:obulamucare/login_screen.dart';
import 'package:obulamucare/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final loginTimestamp = prefs.getInt('loginTimestamp') ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - loginTimestamp;
    const oneDayInMillis = 24 * 60 * 60 * 1000; // 24 hours

    if (isLoggedIn && elapsed < oneDayInMillis) {
      // Session still valid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } else {
      // Session expired or not logged in
      await FirebaseAuth.instance.signOut();
      await prefs.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/vaccinating baby.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox.expand(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(160, 0, 0, 0),
                    Color.fromARGB(159, 27, 49, 59),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: const Text(
                      'OBULAMUCare',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Loading...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orangeAccent,
                          ),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
