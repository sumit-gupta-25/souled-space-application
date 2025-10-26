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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'About Souled Space',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Souled Space is a mindful companion designed to nurture your mental well-being.\n\n'
            'The app focuses on helping users understand and manage stress through effective exercises, journaling, and self-reflection tools.\n\n'
            'It encourages relaxation, emotional balance, and personal growth — creating a safe space for your soul to breathe and heal.',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Text(
                'Souled Space',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.primary),
            title: const Text('About', style: TextStyle(fontSize: 22)),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.primary),
            title: const Text('Logout', style: TextStyle(fontSize: 22)),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(child: body),
    );
  }
}
