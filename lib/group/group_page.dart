import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:souled_space_application/ui_blueprint.dart';

class GroupPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String adminId;
  final List<String> emails;

  const GroupPage({
    super.key,
    required this.groupName,
    required this.groupId,
    required this.adminId,
    required this.emails,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late String groupName;
  late String groupId;
  late String adminId;
  late List<String> emails;

  DatabaseReference get messagesDbReference =>
      FirebaseDatabase.instance.ref().child("messages").child(widget.groupId);
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  void showGroupInfoDialog(
    BuildContext context,
    String adminId,
    List<String> members,
    String groupId,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Admin",
                style: TextStyle(fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 2),
              Text(
                adminId,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 10),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Members",
                  style: TextStyle(fontSize: 14, color: AppColors.primary),
                ),
                const SizedBox(height: 5),

                ...members.map(
                  (email) => Padding(
                    padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Group ID: $groupId",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: AppColors.primary,
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
                "Close",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void sendMessage() {
    final currentUserEmail = currentUser?.email;
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messagesDbReference.push().set({
      'senderId': currentUserEmail,
      'text': text,
      'timestamp': ServerValue.timestamp,
    });

    messageController.clear();
  }

  void listenToMessages() {
    messagesDbReference.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null) {
        setState(() => messages = []);
        return;
      }

      final Map<dynamic, dynamic> map = Map<dynamic, dynamic>.from(data as Map);

      final List<Map<String, dynamic>> loadedMessages = [];

      map.forEach((key, value) {
        final msg = Map<dynamic, dynamic>.from(value);

        loadedMessages.add({
          'sender': msg['senderId'],
          'text': msg['text'],
          'time': msg['timestamp'],
        });
      });

      loadedMessages.sort((a, b) => a['time'].compareTo(b['time']));

      setState(() {
        messages = loadedMessages;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    groupId = widget.groupId;
    groupName = widget.groupName;
    adminId = widget.adminId;
    emails = widget.emails;

    listenToMessages();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = currentUser?.email;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.groupName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showGroupInfoDialog(
                context,
                widget.adminId,
                widget.emails,
                widget.groupId,
              );
            },
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // Messages area
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['sender'] == currentUserEmail;
                  final time = DateTime.fromMillisecondsSinceEpoch(msg['time']);

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color:
                            isMe ? Colors.brown.shade300 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['sender'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            msg['text']!.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
