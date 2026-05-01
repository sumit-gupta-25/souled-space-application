import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); // breathing loop

    _scale = Tween<double>(
      begin: 0.9,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacity = Tween<double>(begin: 0.7, end: 1).animate(_controller);

    // Navigate after 4 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, 'register');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // calm beige

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacity.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.2),
                            blurRadius: 30 * _scale.value,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                );
              },

              child: Image.asset("assets/logo.png", height: 140),
            ),

            const SizedBox(height: 30),

            const Text(
              "Souled Space",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Breathe • Reflect • Heal",
              style: TextStyle(fontSize: 14, color: Colors.brown),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(color: Color(0xFF6D4C41)),
          ],
        ),
      ),
    );
  }
}
