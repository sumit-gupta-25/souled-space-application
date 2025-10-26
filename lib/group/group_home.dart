import 'package:flutter/material.dart';
import 'package:souled_space_application/group/group_page.dart';
import 'package:souled_space_application/ui_blueprint.dart';

class GroupHome extends StatefulWidget {
  const GroupHome({super.key});

  @override
  State<GroupHome> createState() => _GroupHomeState();
}

class _GroupHomeState extends State<GroupHome> {
  final List<String> _groups = [
    'Mindful Warriors',
    'Stress Busters',
    'Daily Achievers',
    'Calm Collective',
    'Zen Masters',
    'Positive Vibes',
    'Support Squad',
    'Happy Minds',
    'Focus Group',
    'Resilient Souls',
  ];

  final TextEditingController _joinController = TextEditingController();

  void _createGroup() {
    // TODO: Add logic for creating a group
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Group'),
            content: const Text('This feature is not implemented yet.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _joinGroup() {
    // Dummy join logic
    String groupName = _joinController.text.trim();
    if (groupName.isNotEmpty && !_groups.contains(groupName)) {
      setState(() {
        _groups.add(groupName);
        _joinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UiTemplate(
      title: 'Souled Space', // AppBar title
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Top row (Groups + icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Groups text
                const Text(
                  'Groups',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),

                // Right side: + icon and mail icon
                Row(
                  children: [
                    IconButton(
                      onPressed: _createGroup,
                      icon: const Icon(Icons.add),
                      color: Colors.brown,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        // TODO: Handle invitations
                      },
                      icon: const Icon(Icons.mail_outline),
                      color: Colors.brown,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Join group row (TextField + join button)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _joinController,
                    decoration: InputDecoration(
                      hintText: 'Enter group name to join',
                      hintStyle: const TextStyle(color: Colors.brown),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5DC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.brown,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _joinGroup,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.group_add,
                      color: Color(0xFFF5F5DC),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Scrollable list of groups
            Expanded(
              child: ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  String groupName = _groups[index];
                  return GestureDetector(
                    onTap: () {
                      // ✅ Navigate to GroupPage when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupPage(groupName: groupName),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        groupName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5DC),
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
