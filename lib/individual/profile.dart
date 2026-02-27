import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String _nickname = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _nickname = 'Guest';
          _isLoading = false;
        });
        return;
      }

      final snapshot =
          await _database.child('users/${user.uid}/nickname').get();
      final nickname = snapshot.value?.toString().trim();

      setState(() {
        _nickname =
            (nickname == null || nickname.isEmpty)
                ? 'No nickname found'
                : nickname;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _nickname = 'Could not load nickname';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F5DC),
          title: const Text(
            'About Souled Space',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Souled Space is a mindful companion designed to nurture your mental well-being.\n\n'
            'The app focuses on helping users understand and manage stress through effective exercises, journaling, and self-reflection tools.\n\n'
            'It encourages relaxation, emotional balance, and personal growth, creating a safe space for your soul to breathe and heal.',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.brown)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.brown,
        foregroundColor: const Color(0xFFF5F5DC),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.brown.shade200,
                backgroundImage:
                    (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                child:
                    (photoUrl == null || photoUrl.isEmpty)
                        ? const Icon(
                          Icons.person,
                          size: 72,
                          color: Color(0xFFF5F5DC),
                        )
                        : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.brown)
                  : Text(
                    _nickname,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAboutDialog,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('About Page'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: const Color(0xFFF5F5DC),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
