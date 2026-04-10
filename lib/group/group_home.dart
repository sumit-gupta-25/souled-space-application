import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:souled_space_application/group/group_page.dart';
import 'package:souled_space_application/ui_blueprint.dart';

class GroupHome extends StatefulWidget {
  const GroupHome({super.key});

  @override
  State<GroupHome> createState() => _GroupHomeState();
}

class _GroupHomeState extends State<GroupHome> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _searchController = TextEditingController();
  final groupsDbReference = FirebaseDatabase.instance.ref('groups');
  final groupInvitesDbReference = FirebaseDatabase.instance.ref('groupInvites');
  final usersDbReference = FirebaseDatabase.instance.ref('users');
  final joinRequestsDbReference = FirebaseDatabase.instance.ref('joinRequests');

  List<Map<String, dynamic>> allGroups = [];
  List<Map<String, dynamic>> visibleGroups = [];

  Future<List<Map<String, String>>> fetchGroupInvites() async {
    final snapshot = await groupInvitesDbReference.get();
    final groupSnapshot = await groupsDbReference.get();
    final email = currentUser?.email;
    List<Map<String, String>> groupNames = [];

    if (snapshot.exists) {
      for (var inviteSnap in snapshot.children) {
        final data = inviteSnap.value as Map<dynamic, dynamic>;

        final groupId = data['groupId']?.toString() ?? '';
        final toUserId = data['toUserId']?.toString() ?? '';

        if (email != null && toUserId.contains(email) == true) {
          if (groupSnapshot.exists) {
            final groupSnap = groupSnapshot.child(groupId);
            if (groupSnap.exists) {
              final inviteId = inviteSnap.key!;
              final data = groupSnap.value as Map<dynamic, dynamic>;
              final groupName = data['name']?.toString() ?? '';
              groupNames.add({
                'inviteId': inviteId,
                'groupId': groupId,
                'groupName': groupName,
              });
            }
          }
        }
      }
    }
    return groupNames;
  }

  Future<void> fetchGroups() async {
    final snapshot = await groupsDbReference.get();
    final List<Map<String, dynamic>> groupList = [];
    final String? email = currentUser?.email;

    if (snapshot.exists) {
      for (var groupSnap in snapshot.children) {
        final groupId = groupSnap.key!;
        final data = Map<dynamic, dynamic>.from(groupSnap.value as Map);
        final name = data['name'] ?? '';
        final adminId = data['adminId'] ?? '';
        final Map<String, String> members = Map<String, String>.from(
          data['members'] ?? {},
        );
        final List<String> emails = members.values.toList();

        if (emails.contains(email!) || adminId == email) {
          groupList.add({
            'groupId': groupId,
            'groupName': name,
            'adminId': adminId,
            'emails': emails,
          });
        }
      }
    }
    setState(() {
      allGroups = groupList;
      visibleGroups = groupList;
    });
  }

  Future<void> createGroupDialog() async {
    final TextEditingController _groupNameController = TextEditingController();
    final TextEditingController _groupMemberController =
        TextEditingController();
    final snapshot = await usersDbReference.get();
    List<String> allEmails = [];
    if (snapshot.exists) {
      for (var userSnap in snapshot.children) {
        final data = userSnap.value as Map<dynamic, dynamic>;
        final email = data['email'];
        if (email != null) allEmails.add(email.toString());
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
              title: Center(child: Text("Create Group")),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _groupNameController,
                        decoration: InputDecoration(
                          labelText: "Group Name",
                          labelStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _groupMemberController,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value.trim().isEmpty) {
                              filteredEmails = [];
                            } else {
                              filteredEmails =
                                  allEmails
                                      .where(
                                        (email) =>
                                            email.toLowerCase().contains(
                                              value.toLowerCase(),
                                            ) &&
                                            !selectedEmails.contains(email) &&
                                            email.toLowerCase() !=
                                                currentUser!.email!
                                                    .toLowerCase(),
                                      )
                                      .toList();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Group Members",
                          labelStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (filteredEmails.isNotEmpty)
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: filteredEmails.length,
                            itemBuilder:
                                (_, i) => ListTile(
                                  title: Text(filteredEmails[i]),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedEmails.add(filteredEmails[i]);
                                      filteredEmails.removeAt(i);
                                    });
                                  },
                                ),
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        children:
                            selectedEmails.map((email) {
                              return Chip(
                                label: Text(email),
                                deleteIcon: Icon(Icons.close),
                                onDeleted: () {
                                  setDialogState(() {
                                    selectedEmails.remove(email);
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
                ),
                TextButton(
                  onPressed: () async {
                    final groupName = _groupNameController.text.trim();
                    if (groupName.isEmpty) return;
                    final newGroupsDbReference = groupsDbReference.push();
                    await newGroupsDbReference.set({
                      'adminId': currentUser?.email,
                      'name': groupName,
                      'members': {},
                    });
                    final groupId = newGroupsDbReference.key;
                    for (String email in selectedEmails) {
                      final newGroupInvitesDbReference =
                          groupInvitesDbReference.push();

                      await newGroupInvitesDbReference.set({
                        'fromAdminId': currentUser?.email,
                        'toUserId': email,
                        'groupId': groupId,
                      });
                    }
                    fetchGroups();
                    Navigator.of(context).pop();
                  },
                  child: Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void openInvites(List<Map<String, String>> requests) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  "Group Invites:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: List.generate(requests.length, (index) {
                    final request = requests[index];
                    final inviteId = request['inviteId']!;
                    final groupId = request['groupId']!;
                    final groupName = request['groupName']!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              groupName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final email = currentUser?.email;
                                  if (email == null) return;

                                  final groupRef = groupsDbReference.child(
                                    groupId,
                                  );

                                  final groupSnapshot = await groupRef.get();

                                  if (!groupSnapshot.exists) {
                                    return;
                                  }

                                  final membersRef = groupRef.child('members');

                                  await membersRef.push().set(email);

                                  await groupInvitesDbReference
                                      .child(inviteId)
                                      .remove();
                                  await fetchGroups();

                                  setDialogState(() {
                                    requests.removeAt(index);
                                  });
                                },
                                child: Text(
                                  "Accept",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  await groupInvitesDbReference
                                      .child(inviteId)
                                      .remove();
                                  setDialogState(() {
                                    requests.removeAt(index);
                                  });
                                },
                                child: Text(
                                  "Reject",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          Divider(thickness: 1, color: Colors.black),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void searchGroups(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        visibleGroups = List.from(allGroups);
      });
      return;
    }

    setState(() {
      visibleGroups =
          allGroups
              .where(
                (group) => group['groupName'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  void joinGroupDialog() {
    final currentEmail = FirebaseAuth.instance.currentUser!.email;
    final searchQuery = ValueNotifier<String>('');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join Group"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔎 Search Bar (we will wire later)
                TextField(
                  onChanged: (value) {
                    searchQuery.value = value.toLowerCase();
                  },
                  decoration: InputDecoration(
                    hintText: "Group Name",
                    hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 📋 Firestore Groups List
                SizedBox(
                  height: 200,
                  child: StreamBuilder(
                    stream:
                        FirebaseDatabase.instance.ref().child('groups').onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return const Center(child: Text("No groups found"));
                      }

                      final data = Map<dynamic, dynamic>.from(
                        snapshot.data!.snapshot.value as Map,
                      );

                      final groupEntries = data.entries.toList();

                      return StreamBuilder(
                        stream:
                            FirebaseDatabase.instance
                                .ref()
                                .child('joinRequests')
                                .onValue,
                        builder: (context, joinSnapshot) {
                          Set<String> requestedGroupIds = {};

                          if (joinSnapshot.hasData &&
                              joinSnapshot.data!.snapshot.value != null) {
                            final joinData = Map<dynamic, dynamic>.from(
                              joinSnapshot.data!.snapshot.value as Map,
                            );

                            joinData.forEach((key, value) {
                              final requestData = Map<dynamic, dynamic>.from(
                                value,
                              );

                              if (requestData['fromUserId'] == currentEmail) {
                                requestedGroupIds.add(requestData['groupId']);
                              }
                            });
                          }

                          final filteredGroups =
                              groupEntries.where((entry) {
                                final groupId = entry.key;
                                final groupData = Map<dynamic, dynamic>.from(
                                  entry.value,
                                );

                                // ❌ already requested
                                if (requestedGroupIds.contains(groupId)) {
                                  return false;
                                }

                                // ❌ admin
                                if (groupData['adminId'] == currentEmail) {
                                  return false;
                                }

                                // ❌ member
                                if (groupData.containsKey('members')) {
                                  final membersMap = Map<dynamic, dynamic>.from(
                                    groupData['members'],
                                  );

                                  if (membersMap.values.contains(
                                    currentEmail,
                                  )) {
                                    return false;
                                  }
                                }

                                return true;
                              }).toList();

                          return ListView.builder(
                            itemCount: filteredGroups.length,
                            itemBuilder: (context, index) {
                              final groupId = filteredGroups[index].key;

                              final groupData = Map<dynamic, dynamic>.from(
                                filteredGroups[index].value,
                              );

                              final groupName = groupData['name'] ?? '';

                              return Card(
                                child: ListTile(
                                  title: Text(
                                    groupName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    groupId,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 8,
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final requestRef =
                                            FirebaseDatabase.instance
                                                .ref()
                                                .child('joinRequests')
                                                .push();

                                        await requestRef.set({
                                          'groupId': groupId,
                                          'fromUserId': currentEmail,
                                        });
                                      },
                                      child: const Text(
                                        "Send\nRequest",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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
  void initState() {
    super.initState();
    fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return UiTemplate(
      title: 'Souled Space',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Groups', style: TextStyle(fontSize: 24)),
                Row(
                  children: [
                    IconButton(
                      onPressed: createGroupDialog,
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () async {
                        final List<Map<String, String>> groupNames =
                            await fetchGroupInvites();
                        openInvites(groupNames);
                      },
                      icon: const Icon(Icons.mail_outline),
                    ),
                  ],
                ),
              ],
            ),
            TextField(
              controller: _searchController,
              onChanged: searchGroups,
              decoration: InputDecoration(
                hintText: 'Search groups',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    searchGroups('');
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.group_add),
                onPressed: joinGroupDialog,
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: visibleGroups.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final group = visibleGroups[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.all(5),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.brown.shade400,
                      child: Text(
                        group['groupName'][0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade50,
                        ),
                      ),
                    ),
                    title: Text(
                      group['groupName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Tap to open group",
                      style: TextStyle(color: Colors.brown.shade800),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => GroupPage(
                                groupId: group['groupId'],
                                groupName: group['groupName'],
                                adminId: group['adminId'],
                                emails: List<String>.from(group['emails']),
                              ),
                        ),
                      );
                    },
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
