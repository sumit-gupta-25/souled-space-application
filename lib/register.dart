import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  MyRegisterState createState() => MyRegisterState();
}

class MyRegisterState extends State<MyRegister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || nickname.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firebase Auth - Create User
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Firebase Database - Save user info
      final userId = userCredential.user?.uid;
      await _database.child('users/$userId').set({
        'name': name,
        'nickname': nickname,
        'email': email,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));

      // Navigate to Login page
      Navigator.pushNamed(context, 'login');
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 100),
            child: const Text(
              'Create\nAccount',
              style: TextStyle(color: Color(0xFFF8F8F8), fontSize: 33),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.3,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                children: [
                  // Name
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Color(0xFFF8F8F8)),
                    decoration: _inputDecoration('Name', Icons.person),
                  ),
                  const SizedBox(height: 20),

                  // Nickname
                  TextField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Color(0xFFF8F8F8)),
                    decoration: _inputDecoration('Nickname', Icons.tag_faces),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFFF8F8F8)),
                    decoration: _inputDecoration('Email', Icons.email),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Color(0xFFF8F8F8)),
                    obscureText: true,
                    decoration: _inputDecoration('Password', Icons.lock),
                  ),
                  const SizedBox(height: 40),

                  // Sign Up Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFFF8F8F8),
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFF8F8F8),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.brown,
                                )
                                : IconButton(
                                  color: Colors.brown,
                                  onPressed: _registerUser,
                                  icon: const Icon(Icons.arrow_forward),
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Sign In link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'login');
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFFF8F8F8),
                            fontSize: 18,
                          ),
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF8F8F8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.brown),
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFF8F8F8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: Icon(icon, color: Color(0xFFF8F8F8)),
    );
  }
}
