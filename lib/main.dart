import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:obulamucare/firebase_options.dart';
import 'package:obulamucare/login_screen.dart';
import 'package:obulamucare/splash.dart';

// Add other screens as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      //  Define the initial route
      initialRoute: '/splash',

      // Define named routes
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login_screen': (context) => const LoginScreen(),

        // Add other screens like OTP, Home, etc.
      },
    );
  }
}
