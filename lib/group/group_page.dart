import 'dart:math';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  final String groupName;

  const GroupPage({super.key, required this.groupName});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  double stressLevel = 68;

  // Dummy chat messages
  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'Alice',
      'message': 'Completed today’s meditation session!',
      'isMe': false,
      'reactions': <String, int>{},
    },
    {
      'sender': 'You',
      'message': 'That’s awesome! I did yoga today.',
      'isMe': true,
      'reactions': <String, int>{},
    },
    {
      'sender': 'Bob',
      'message': 'Feeling much calmer after journaling.',
      'isMe': false,
      'reactions': <String, int>{},
    },
    {
      'sender': 'You',
      'message': 'Same here 😊',
      'isMe': true,
      'reactions': <String, int>{},
    },
  ];

  // Dummy group members
  final List<String> groupMembers = ['Alice', 'Bob', 'Charlie', 'You'];

  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'You',
        'message': text,
        'isMe': true,
        'reactions': <String, int>{},
      });
      _messageController.clear();
    });
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F5DC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Group Members',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                const SizedBox(height: 10),
                ...groupMembers.map(
                  (member) => ListTile(
                    leading: const Icon(Icons.person, color: Colors.brown),
                    title: Text(
                      member,
                      style: const TextStyle(color: Colors.brown, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Reaction popup on long-press
  void _showReactionPopup(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                ['👍', '❤️', '👏', '🎉'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        messages[index]['reactions'][emoji] =
                            (messages[index]['reactions'][emoji] ?? 0) + 1;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(double value) {
      if (value <= 50) return Colors.green;
      if (value <= 75) return Colors.yellow[700]!;
      return Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Colors.brown,
        foregroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFF5F5DC)),
            onPressed: _showGroupInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Stress Index
          const Text(
            'Group Stress Index',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 10),

          // Gauge
          SizedBox(
            width: 220,
            height: 120,
            child: CustomPaint(
              painter: SpeedometerPainter(stressLevel, getColor(stressLevel)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${stressLevel.toInt()}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Stress Level'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'] as bool;

                return GestureDetector(
                  onLongPress: () => _showReactionPopup(index),
                  child: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.brown : const Color(0xFFF5F5DC),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              msg['sender'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          Text(
                            msg['message'],
                            style: TextStyle(
                              color:
                                  isMe ? const Color(0xFFF5F5DC) : Colors.brown,
                              fontSize: 16,
                            ),
                          ),

                          // Show reactions below message
                          if (msg['reactions'] != null &&
                              msg['reactions'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Wrap(
                                spacing: 6,
                                children:
                                    msg['reactions'].entries.map<Widget>((e) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text('${e.key} ${e.value}'),
                                      );
                                    }).toList(),
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

          // Input box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFFF5F5DC),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts here',
                      hintStyle: const TextStyle(color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.brown),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.send, color: Color(0xFFF5F5DC)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for stress gauge
class SpeedometerPainter extends CustomPainter {
  final double value;
  final Color color;

  SpeedometerPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2.2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15
          ..strokeCap = StrokeCap.round
          ..color = Colors.grey[300]!;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      paint,
    );

    // Active arc
    final sweepAngle = (value / 100) * pi;
    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
