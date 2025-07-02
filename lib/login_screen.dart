
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:obulamucare/dashboard.dart';

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
      // signin with email and password firebaseAuth below
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // Check if the user is signed in
      if (userCredential.user == null) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );

        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('userEmail', userCredential.user?.email ?? '');
      await prefs.setString('userId', userCredential.user?.uid ?? '');
      await prefs.setBool('isLoggedIn', true);

      // Navigate to the next screen or show success message
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Login Screen"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/lock.png', width: 300, height: 200),
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "Login Here!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(color: Colors.black54, height: 20),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    suffixIcon: Icon(Icons.email),
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
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: Icon(Icons.lock),
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
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSubmitting ? "Logging In....." : 'Sign In',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Icon(Icons.person_add, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
