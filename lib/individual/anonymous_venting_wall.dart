import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:souled_space_application/ui_blueprint.dart';

class AnonymousVentingWall extends StatefulWidget {
  const AnonymousVentingWall({super.key});

  @override
  State<AnonymousVentingWall> createState() => _AnonymousVentingWallState();
}

class _AnonymousVentingWallState extends State<AnonymousVentingWall> {
  final TextEditingController _ventController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();

  String? _nickname;
  List<Map<String, dynamic>> _ventList = [];

  @override
  void initState() {
    super.initState();
    _fetchNickname();
    _listenToVents();
  }

  Future<void> _fetchNickname() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot =
          await _database.child('users/${user.uid}/nickname').get();

      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          _nickname = snapshot.value.toString();
        });
      }
    } catch (e) {
      debugPrint('Error fetching nickname: $e');
    }
  }

  void _listenToVents() {
    _database.child('vents').onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data == null) {
        setState(() => _ventList = []);
        return;
      }

      final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> tempList = [];

      map.forEach((key, value) {
        tempList.add({
          'id': key,
          'uid': value['uid'] ?? '',
          'nickname': value['nickname'] ?? 'Anonymous',
          'text': value['text'] ?? '',
          'time': value['time'] ?? '',
        });
      });

      // Sort oldest to newest
      tempList.sort((a, b) => a['time'].compareTo(b['time']));
      setState(() => _ventList = tempList);

      // Scroll to bottom when new messages arrive
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  Future<void> _postVenting() async {
    if (_ventController.text.trim().isEmpty) return;

    if (_nickname == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch your nickname yet. Try again.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final user = _auth.currentUser;

    await _database.child('vents').push().set({
      'uid': user?.uid ?? '',
      'nickname': _nickname,
      'text': _ventController.text.trim(),
      'time': formattedTime,
    });

    _ventController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return UiTemplate(
      title: 'Anonymous Venting Wall',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            // Vents list
            Expanded(
              child:
                  _ventList.isEmpty
                      ? const Center(
                        child: Text(
                          'No posts yet. Let it out!',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: _ventList.length,
                        itemBuilder: (context, index) {
                          final vent = _ventList[index];
                          final isMe = vent['uid'] == _auth.currentUser?.uid;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            alignment: Alignment.center, // Center all messages
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isMe
                                          ? Colors.brown[400]
                                          : const Color(0xFFF5F5DC),
                                  border:
                                      isMe
                                          ? null
                                          : Border.all(
                                            color: Colors.brown,
                                            width: 1.5,
                                          ), // border for received msgs
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vent['nickname'],
                                      style: TextStyle(
                                        color:
                                            isMe
                                                ? const Color(0xFFF5F5DC)
                                                : Colors.brown,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vent['text'],
                                      style: TextStyle(
                                        color:
                                            isMe
                                                ? const Color(0xFFF5F5DC)
                                                : Colors.brown[900],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatTime(vent['time']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isMe
                                                  ? const Color(0xFFF5F5DC)
                                                  : Colors.brown[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Input field
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5DC),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.brown, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ventController,
                      style: const TextStyle(fontSize: 16, color: Colors.brown),
                      decoration: const InputDecoration(
                        hintText: "Type something...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _postVenting,
                    icon: const Icon(Icons.send, color: Colors.brown),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(time);
      return DateFormat('dd MMM, hh:mm a').format(dateTime);
    } catch (_) {
      return time;
    }
  }
}
