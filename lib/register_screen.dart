import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:obulamucare/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _selectedDate;
  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _selectedGender;
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final payLoad = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'gender': _selectedGender,
        'dateOfBirth': _dateController.text,
        'password': _passwordController.text,
      };

      // Save user to Firestore and create Firebase Auth account
      try {
        // Import these at the top of your file:
        // import 'package:cloud_firestore/cloud_firestore.dart';
        // import 'package:firebase_auth/firebase_auth.dart';

        // Create user in Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Save user details to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(payLoad);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.message}')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        return;
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful! Data: $payLoad')),
      );
      // Optionally, navigate to another screen after successful registration
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/pngwing.com.png', width: 300, height: 200),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    suffixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    suffixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
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
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    suffixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    suffixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    suffixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Gender';
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
                      borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your confirm password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                
                ElevatedButton(
                  onPressed: _signUp,
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
                        'Create Account',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.person_add, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  // Removed duplicate _signUp() method as the correct one is already defined above.

  }}