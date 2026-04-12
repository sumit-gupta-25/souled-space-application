import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:souled_space_application/ui_blueprint.dart';
import 'package:souled_space_application/services/ai_moderation_service.dart';

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
  final groupsDbReference = FirebaseDatabase.instance.ref('groups');
  final groupInvitesDbReference = FirebaseDatabase.instance.ref('groupInvites');
  final usersDbReference = FirebaseDatabase.instance.ref('users');
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

  void sendMessage() async {
    final currentUserEmail = currentUser?.email;
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    // AI Moderation
    final result = await AiModerationService.checkText(text);

    if (result["decision"] == "block") {
      _showBlockedDialog(result["reason"]);
      return;
    }

    if (result["decision"] == "warn") {
      _showBlockedDialog("Please use respectful language.");
      return;
    }

    // Send message if allowed
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

  void showJoinRequestsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join Requests"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StreamBuilder(
              stream:
                  FirebaseDatabase.instance.ref().child('joinRequests').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No requests found"));
                }

                final data = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                // 🔥 Filter requests for current group
                final groupRequests =
                    data.entries.where((entry) {
                      final requestData = Map<dynamic, dynamic>.from(
                        entry.value,
                      );

                      return requestData['groupId'] == widget.groupId;
                    }).toList();

                if (groupRequests.isEmpty) {
                  return const Center(child: Text("No pending requests"));
                }

                return ListView.builder(
                  itemCount: groupRequests.length,
                  itemBuilder: (context, index) {
                    final requestId = groupRequests[index].key;

                    final requestData = Map<dynamic, dynamic>.from(
                      groupRequests[index].value,
                    );

                    final userEmail = requestData['fromUserId'];

                    return Card(
                      child: ListTile(
                        title: Text(userEmail),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ ACCEPT
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                await FirebaseDatabase.instance
                                    .ref()
                                    .child('groups')
                                    .child(widget.groupId)
                                    .child('members')
                                    .push()
                                    .set(userEmail);

                                await FirebaseDatabase.instance
                                    .ref()
                                    .child('joinRequests')
                                    .child(requestId)
                                    .remove();
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await FirebaseDatabase.instance
                                    .ref()
                                    .child('joinRequests')
                                    .child(requestId)
                                    .remove();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> showAddMembersDialog() async {
    final TextEditingController _memberController = TextEditingController();

    // Fetch all users
    final usersSnapshot = await usersDbReference.get();
    List<String> allEmails = [];

    if (usersSnapshot.exists) {
      for (var userSnap in usersSnapshot.children) {
        final data = userSnap.value as Map<dynamic, dynamic>;
        final email = data['email'];
        if (email != null) {
          allEmails.add(email.toString());
        }
      }
    }

    // Fetch current group data
    final groupSnapshot = await groupsDbReference.child(widget.groupId).get();

    String? adminId;
    List<String> existingMembers = [];

    if (groupSnapshot.exists) {
      final groupData = groupSnapshot.value as Map<dynamic, dynamic>;

      adminId = groupData['adminId'];

      if (groupData['members'] != null) {
        final membersMap = Map<dynamic, dynamic>.from(groupData['members']);
        existingMembers = membersMap.values.map((e) => e.toString()).toList();
      }
    }

    List<String> filteredEmails = [];
    List<String> selectedEmails = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Center(child: Text("Add Members")),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔎 Search Field
                      TextField(
                        controller: _memberController,
                        decoration: const InputDecoration(hintText: "Members"),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value.trim().isEmpty) {
                              filteredEmails = [];
                            } else {
                              filteredEmails =
                                  allEmails.where((email) {
                                    final lower = email.toLowerCase();

                                    return lower.contains(
                                          value.toLowerCase(),
                                        ) &&
                                        lower !=
                                            currentUser!.email!.toLowerCase() &&
                                        lower != adminId?.toLowerCase() &&
                                        !existingMembers
                                            .map((e) => e.toLowerCase())
                                            .contains(lower) &&
                                        !selectedEmails.contains(email);
                                  }).toList();
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // 🔽 Suggestions
                      if (filteredEmails.isNotEmpty)
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: filteredEmails.length,
                            itemBuilder:
                                (_, index) => ListTile(
                                  title: Text(filteredEmails[index]),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedEmails.add(filteredEmails[index]);
                                      filteredEmails.removeAt(index);
                                    });
                                  },
                                ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // 🏷 Selected Chips
                      Wrap(
                        spacing: 8,
                        children:
                            selectedEmails
                                .map(
                                  (email) => Chip(
                                    label: Text(email),
                                    deleteIcon: const Icon(Icons.close),
                                    onDeleted: () {
                                      setDialogState(() {
                                        selectedEmails.remove(email);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔘 Buttons
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
                TextButton(
                  onPressed: () async {
                    for (String email in selectedEmails) {
                      final newInviteRef = groupInvitesDbReference.push();

                      await newInviteRef.set({
                        'fromAdminId': currentUser?.email,
                        'toUserId': email,
                        'groupId': widget.groupId,
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Send"),
                ),
              ],
            );
          },
        );
      },
    );
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
          if (FirebaseAuth.instance.currentUser!.email == widget.adminId) ...[
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                showAddMembersDialog();
              },
            ),

            IconButton(
              icon: const Icon(Icons.pending_actions),
              onPressed: () {
                showJoinRequestsDialog(context);
              },
            ),
          ],

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
