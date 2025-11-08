import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class MyJournals extends StatefulWidget {
  const MyJournals({super.key});

  @override
  State<MyJournals> createState() => MyJournalsState();
}

class MyJournalsState extends State<MyJournals> {
  final _auth = FirebaseAuth.instance;
  late DatabaseReference _userJournalsRef;
  List<Map<String, dynamic>> journals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _userJournalsRef = FirebaseDatabase.instance
          .ref()
          .child('journals')
          .child(userId);
      fetchJournals();
    }
  }

  Future<void> fetchJournals() async {
    final snapshot = await _userJournalsRef.get();
    List<Map<String, dynamic>> loadedJournals = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        loadedJournals.add({
          'id': key,
          'name': value['name'] ?? '',
          'content': value['content'] ?? '',
          'createdAt': value['createdAt'] ?? '',
        });
      });
    }

    // ✅ Sort by creation date (newest first)
    loadedJournals.sort((a, b) {
      try {
        final dateA = DateFormat('yyyy-MM-dd HH:mm').parse(a['createdAt']);
        final dateB = DateFormat('yyyy-MM-dd HH:mm').parse(b['createdAt']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      journals = loadedJournals;
      isLoading = false;
    });
  }

  Future<void> _saveJournal(
    String name,
    String content, {
    String? existingId,
  }) async {
    if (name.trim().isEmpty || content.trim().isEmpty) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Ensure unique journal name for same user
    final duplicate = journals.any(
      (j) =>
          j['name'].toLowerCase() == name.toLowerCase() &&
          j['id'] != existingId,
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal name must be unique.')),
      );
      return;
    }

    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    if (existingId != null) {
      await _userJournalsRef.child(existingId).update({
        'name': name,
        'content': content,
        'createdAt': now,
      });
    } else {
      await _userJournalsRef.push().set({
        'name': name,
        'content': content,
        'createdAt': now,
      });
    }

    fetchJournals();
    Navigator.pop(context);
  }

  Future<void> _deleteJournal(String id) async {
    await _userJournalsRef.child(id).remove();
    fetchJournals();
  }

  void _showJournalPopup({Map<String, dynamic>? existingJournal}) {
    final nameController = TextEditingController(
      text: existingJournal?['name'] ?? '',
    );
    final contentController = TextEditingController(
      text: existingJournal?['content'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            existingJournal == null ? 'New Journal' : 'Edit Journal',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          content: SizedBox(
            height: 250,
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Journal Name',
                    labelStyle: TextStyle(color: Colors.brown),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts...',
                      hintStyle: TextStyle(color: Colors.brown),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.brown),
              ),
            ),
            ElevatedButton(
              onPressed:
                  () => _saveJournal(
                    nameController.text,
                    contentController.text,
                    existingId: existingJournal?['id'],
                  ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFFF5F5DC)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text('My Journals'),
        centerTitle: true,
        foregroundColor: Color(0xFFF5F5DC),
        backgroundColor: Colors.brown,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              )
              : journals.isEmpty
              ? const Center(
                child: Text(
                  'No journals yet!\nClick the + button to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: journals.length,
                itemBuilder: (context, index) {
                  final journal = journals[index];
                  return Card(
                    color: const Color(0xFFFFF8E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.brown),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () => _showJournalPopup(existingJournal: journal),
                      title: Text(
                        journal['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Created on: ${journal['createdAt']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.brown),
                        onPressed: () => _deleteJournal(journal['id']),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJournalPopup(),
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Color(0xFFF5F5DC)),
      ),
    );
  }
}
