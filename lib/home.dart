import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:souled_space_application/services/stress_detection_service.dart';
import 'dart:ui';
import 'package:souled_space_application/services/ai_moderation_service.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final TextEditingController _ventController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();

  String? _nickname;
  List<Map<String, dynamic>> _ventList = [];
  bool _isAnalyzing = false;

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
          'stress_level': value['stress_level'] ?? 0,
          'prediction': value['prediction'] ?? '',
          'likes': value['likes'] ?? {},
          'comments': value['comments'] ?? {},
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

  Future<void> _showBlockedDialog(String reason) async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Message Blocked 🚫"),
            content: Text(
              "Your message contains harmful content.\nReason: $reason",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
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

    setState(() => _isAnalyzing = true);

    try {
      // AI Moderation Service
      final result = await AiModerationService.checkText(
        _ventController.text.trim(),
      );

      if (result["decision"] == "block") {
        _showBlockedDialog(
          "This message may harm others' mental well-being. Please rephrase.",
        );
        setState(() => _isAnalyzing = false);
        return;
      }

      // Treat WARN as BLOCK (for safety)
      if (result["decision"] == "warn") {
        _showBlockedDialog(
          "This content may negatively affect someone's mental health. Please use kind language.",
        );
        setState(() => _isAnalyzing = false);
        return;
      }

      // Analyze text with ML model
      final analysisResult = await StressDetectionService.analyzeText(
        _ventController.text.trim(),
      );

      final stressLevel = analysisResult?['stress_level'] ?? 50.0;
      final prediction = analysisResult?['prediction'] ?? 'unknown';

      final now = DateTime.now();
      final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      final user = _auth.currentUser;

      // Save to Firebase with stress level and prediction
      await _database.child('vents').push().set({
        'uid': user?.uid ?? '',
        'nickname': _nickname,
        'text': _ventController.text.trim(),
        'time': formattedTime,
        'stress_level': stressLevel,
        'prediction': prediction,
        'likes': {},
        'comments': {},
      });

      _ventController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Posted! Stress Level: ${stressLevel.toInt()}%'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error posting: $e')));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(time);
      return DateFormat('dd MMM, hh:mm a').format(dateTime);
    } catch (_) {
      return time;
    }
  }

  void _showPostPopup() {
    _ventController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5DC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Let It Out 🤍",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _ventController,
                    maxLines: 6,
                    autofocus: true,
                    style: const TextStyle(fontSize: 18, color: Colors.brown),
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_ventController.text.length} characters",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.brown,
                        ),
                      ),

                      _isAnalyzing
                          ? const CircularProgressIndicator(color: Colors.brown)
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: const Color(0xFFF5F5DC),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await _postVenting();
                            },
                            child: const Text("Post"),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleLike(String postId, Map likes) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _database.child('vents/$postId/likes');

    if (likes.containsKey(userId)) {
      await postRef.child(userId).remove();
    } else {
      await postRef.child(userId).set(true);
    }
  }

  String _formatCommentTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      return DateFormat('dd MMM • hh:mm a').format(dateTime);
    } catch (_) {
      return time;
    }
  }

  void _showCommentsPopup(String postId) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5DC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.brown[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Comments",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),

                const SizedBox(height: 10),

                /// COMMENT LIST
                Expanded(
                  child: StreamBuilder(
                    stream: _database.child('vents/$postId/comments').onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return const Center(child: Text("No comments yet"));
                      }

                      final data =
                          snapshot.data!.snapshot.value
                              as Map<dynamic, dynamic>;

                      final commentEntries = data.entries.toList();

                      return ListView.builder(
                        itemCount: commentEntries.length,
                        itemBuilder: (context, index) {
                          final key = commentEntries[index].key;
                          final comment = Map<String, dynamic>.from(
                            commentEntries[index].value,
                          );

                          final isMyComment =
                              comment['uid'] == _auth.currentUser?.uid;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),

                              title: Text(
                                comment['nickname'] ?? "Anonymous",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment['text'] ?? ''),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCommentTime(comment['time'] ?? ''),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),

                              trailing:
                                  isMyComment
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          await _database
                                              .child(
                                                'vents/$postId/comments/$key',
                                              )
                                              .remove();
                                        },
                                      )
                                      : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                /// INPUT FIELD
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.brown.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: "Write a comment...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.brown),
                        onPressed: () async {
                          final user = _auth.currentUser;
                          final text = commentController.text.trim();

                          if (user == null || text.isEmpty) return;

                          // AI moderation check for comment
                          final result = await AiModerationService.checkText(
                            text,
                          );

                          if (result["decision"] == "block") {
                            _showBlockedDialog(
                              "This message may harm others' mental well-being. Please rephrase.",
                            );
                            return;
                          }

                          // Treat WARN as BLOCK (for safety)
                          if (result["decision"] == "warn") {
                            _showBlockedDialog(
                              "This content may negatively affect someone's mental health. Please use kind language.",
                            );
                            return;
                          }

                          await _database
                              .child('vents/$postId/comments')
                              .push()
                              .set({
                                'uid': user.uid,
                                'nickname': _nickname,
                                'text': commentController.text.trim(),
                                'time': DateTime.now().toIso8601String(),
                              });

                          commentController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text(
          'Souled Space',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: const Color(0xFFF5F5DC),
      ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DC),
          border: Border(top: BorderSide(color: Colors.brown.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left Side Icons
            IconButton(
              icon: Icon(
                Icons.psychology_alt_rounded,
                size: 30,
                color: _selectedIndex == 0 ? Colors.brown : Colors.grey,
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'cbt_reflection');
                _onItemTapped(0);
              },
            ),

            IconButton(
              icon: Icon(
                Icons.thermostat,
                size: 30,
                color: _selectedIndex == 1 ? Colors.brown : Colors.grey,
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'stress_thermometer');
                _onItemTapped(1);
              },
            ),

            // Center + Button
            GestureDetector(
              onTap: _showPostPopup,
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.brown),
              ),
            ),

            // Right Side Icons
            IconButton(
              icon: Icon(
                Icons.group_rounded,
                size: 30,
                color: _selectedIndex == 3 ? Colors.brown : Colors.grey,
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'group');
                _onItemTapped(3);
              },
            ),

            IconButton(
              icon: Icon(
                Icons.person_rounded,
                size: 30,
                color: _selectedIndex == 4 ? Colors.brown : Colors.grey,
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'profile');
                _onItemTapped(4);
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                          final commentCount =
                              (vent['comments'] as Map?)?.length ?? 0;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.92,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isMe
                                          ? const Color(0xFFF5F5DC)
                                          : Colors.brown[400],
                                  border:
                                      isMe
                                          ? Border.all(
                                            color: Colors.brown,
                                            width: 1.5,
                                          )
                                          : null,
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
                                                ? Colors.brown
                                                : const Color(0xFFF5F5DC),
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
                                                ? Colors.brown
                                                : const Color(0xFFF5F5DC),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const SizedBox(height: 8),

                                    // Action Row (Like + Comment)
                                    Row(
                                      children: [
                                        Builder(
                                          builder: (_) {
                                            final likes =
                                                Map<String, dynamic>.from(
                                                  vent['likes'] ?? {},
                                                );
                                            final userId =
                                                _auth.currentUser?.uid;
                                            final isLiked = likes.containsKey(
                                              userId,
                                            );
                                            final likeCount = likes.length;

                                            return Row(
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color:
                                                        isLiked
                                                            ? Colors.red
                                                            : isMe
                                                            ? Colors.brown
                                                            : const Color(
                                                              0xFFF5F5DC,
                                                            ),
                                                    size: 22,
                                                  ),
                                                  onPressed:
                                                      () => _toggleLike(
                                                        vent['id'],
                                                        likes,
                                                      ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  likeCount.toString(),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        isMe
                                                            ? Colors.brown
                                                            : const Color(
                                                              0xFFF5F5DC,
                                                            ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),

                                        const SizedBox(width: 16),

                                        Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: Icon(
                                                Icons.chat_bubble_outline,
                                                size: 20,
                                                color:
                                                    isMe
                                                        ? Colors.brown
                                                        : const Color(
                                                          0xFFF5F5DC,
                                                        ),
                                              ),
                                              onPressed: () {
                                                _showCommentsPopup(vent['id']);
                                              },
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              commentCount.toString(),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    isMe
                                                        ? Colors.brown
                                                        : const Color(
                                                          0xFFF5F5DC,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // Time (Small & Subtle)
                                    Text(
                                      _formatTime(vent['time']),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            isMe
                                                ? Colors.brown
                                                : const Color(0xFFF5F5DC),
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
          ],
        ),
      ),
    );
  }
}
