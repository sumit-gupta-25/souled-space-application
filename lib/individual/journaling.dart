import 'package:flutter/material.dart';
import 'package:souled_space_application/ui_blueprint.dart';

class Journaling extends StatefulWidget {
  const Journaling({super.key});

  @override
  JournalingState createState() => JournalingState();
}

class JournalingState extends State<Journaling> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return UiTemplate(
      title: 'Journaling',
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 60, top: 50, right: 35),
            child: Text(
              '"Let Your Diary Carry\nWhat Burdens You..."',
              style: TextStyle(
                color: Colors.brown,
                fontSize: 30,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
                decorationColor: Colors.brown,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, top: 180, right: 10),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                height: 500,
                width: 350,
                child: TextField(
                  maxLength: 5000,
                  onChanged: (value) {
                    setState(() {});
                  },
                  buildCounter: (
                    context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return Text(
                      '$currentLength / $maxLength',
                      style: TextStyle(color: Colors.brown),
                    );
                  },
                  controller: _textController,
                  maxLines: 16,
                  style: TextStyle(color: Colors.brown, fontSize: 18),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    hintText: "Enter Your thoughts",
                    hintStyle: TextStyle(color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, 'myjournals');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.my_library_books,
                      color: Color(0xFFF5F5DC),
                    ),
                    label: const Text(
                      'My Journals',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF5F5DC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.backup_outlined,
                      color: Color(0xFFF5F5DC),
                    ),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF5F5DC),
                        fontWeight: FontWeight.bold,
                      ),
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

class MyJournals extends StatefulWidget {
  const MyJournals({super.key});

  @override
  State<MyJournals> createState() => MyJournalsState();
}

class MyJournalsState extends State<MyJournals> {
  List<String> entries = [];

  @override
  void initState() {
    super.initState();
    fetchEntries(); // load entries from database
  }

  Future<void> fetchEntries() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      entries = ['First saved thought', 'Second saved memory'];
    });
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
          entries.isEmpty
              ? const Center(
                child: Text(
                  'No entries yet.\nStart writing your thoughts!',
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
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFFFFF8E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.brown),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Journal ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          entries[index],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
