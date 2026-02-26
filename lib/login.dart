import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  MyLoginState createState() => MyLoginState();
}

class MyLoginState extends State<MyLogin> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  // 🔹 Login function
  Future<void> _loginUser() async {
    String email = _emailTextController.text.trim();
    String password = _passwordTextController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // ✅ Success
      _showMessage("Login successful!");
      Navigator.pushReplacementNamed(context, 'home');
    } on FirebaseAuthException catch (e) {
      // ❌ Common error messages
      String message = "An error occurred.";
      if (e.code == 'user-not-found') {
        message = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      }

      _showMessage(message);
    } catch (e) {
      _showMessage("Something went wrong. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔹 Show snack message
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 130),
            child: const Text(
              'Welcome\nBack',
              style: TextStyle(color: Color(0xFFF8F8F8), fontSize: 33),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 35, right: 35),
                    child: Column(
                      children: [
                        // Email TextField
                        TextField(
                          controller: _emailTextController,
                          style: const TextStyle(color: Color(0xFFF8F8F8)),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFF8F8F8),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFF8F8F8),
                              ),
                            ),
                            hintText: "Email",
                            hintStyle: const TextStyle(
                              color: Color(0xFFF8F8F8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFFF8F8F8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Password TextField
                        TextField(
                          controller: _passwordTextController,
                          style: const TextStyle(color: Color(0xFFF8F8F8)),
                          obscureText: true,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFF8F8F8),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFF8F8F8),
                              ),
                            ),
                            hintText: "Password",
                            hintStyle: const TextStyle(
                              color: Color(0xFFF8F8F8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFFF8F8F8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Sign in button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sign in',
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
                                        onPressed: _loginUser,
                                        icon: const Icon(Icons.arrow_forward),
                                      ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Sign up button
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'register');
                              },
                              child: const Text(
                                'Sign Up',
                                textAlign: TextAlign.right,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
