import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F5DC); // Beige
  static const Color primary = Colors.brown; // Brown
  static const Color text = Colors.brown; // Brown text
}

class UiTemplate extends StatelessWidget {
  final String title;
  final Widget body;

  const UiTemplate({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(child: body),
    );
  }
}
