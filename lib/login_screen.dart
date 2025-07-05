import 'dart:ui'; // For ImageFilter.blur
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:obulamucare/dashboard.dart';
import 'package:obulamucare/register_screen.dart'; // <-- make sure this exists
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        if (userCredential.user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', userCredential.user?.email ?? '');
          await prefs.setString('userId', userCredential.user?.uid ?? '');
          await prefs.setBool('isLoggedIn', true);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login successful! Welcome ${userCredential.user?.email}',
              ),
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user found. Redirecting to registration...'),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wrong password provided.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again.')),
          );
        }
        setState(() {
          _isSubmitting = false;
        });
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/vaccinating baby.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient + blur overlay
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
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 6),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/passwordlo.png',
                      width: 300,
                      height: 200,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Login Here!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(color: Colors.white70, height: 20),
                    const SizedBox(height: 20),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: const TextStyle(color: Colors.white70),
                        suffixIcon: const Icon(
                          Icons.email,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        } else if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        suffixIcon: const Icon(
                          Icons.lock,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // Login button
                    ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSubmitting ? "Logging In..." : 'Sign In',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          _isSubmitting
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : const Icon(Icons.login, color: Colors.white),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Register navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
