import 'dart:ui';
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _selectedDate;

  String? _selectedGender;

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

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(payLoad);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration Successful! Welcome, ${_nameController.text}',
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color.fromARGB(221, 96, 22, 167),
      ),
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/vaccinating baby.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient and blur overlay
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
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Foreground form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/pngwing.com.png',
                    width: 300,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, "Full Name", Icons.person),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 16),
                  _buildDatePickerField(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _addressController,
                    "Address",
                    Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  _buildGenderDropdown(),
                  const SizedBox(height: 16),
                  _buildPasswordField(_passwordController, "Password"),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
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
                    child: const Row(
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
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: const Icon(Icons.email, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: const Icon(Icons.phone, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField() {
    return TextFormField(
      controller: _dateController,
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      validator:
          (_) =>
              _selectedDate == null ? 'Please select your date of birth' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      dropdownColor: Colors.black87,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: const Icon(Icons.person, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      style: const TextStyle(color: Colors.white),
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
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please select Gender' : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: const Icon(Icons.lock, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        } else if (value.length < 6) {
          return '$label must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      style: const TextStyle(color: Colors.white),
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: const Icon(Icons.lock, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        } else if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
