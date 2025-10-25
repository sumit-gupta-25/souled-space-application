import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:souled_space_application/ui_blueprint.dart';

class AnonymousVentingWall extends StatefulWidget {
  const AnonymousVentingWall({super.key});

  @override
  State<AnonymousVentingWall> createState() => _AnonymousVentingWallState();
}

class _AnonymousVentingWallState extends State<AnonymousVentingWall> {
  final TextEditingController _ventController = TextEditingController();
  final List<Map<String, dynamic>> _ventList = []; // Stores text + time

  void _postVenting() {
    if (_ventController.text.trim().isEmpty) return;

    final now = DateTime.now();
    final formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    setState(() {
      _ventList.insert(0, {
        'text': _ventController.text.trim(),
        'time': formattedTime,
      });
      _ventController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return UiTemplate(
      title: 'Anonymous Venting Wall',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Express yourself freely...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),

            // Input box for typing vent
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5DC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown, width: 2),
              ),
              child: TextField(
                controller: _ventController,
                maxLines: 4,
                style: const TextStyle(fontSize: 18, color: Colors.brown),
                decoration: const InputDecoration(
                  hintText: 'Type your thoughts here...',
                  hintStyle: TextStyle(color: Colors.brown),
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Post button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _postVenting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Post Anonymously',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFF5F5DC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Vent list
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
                        itemCount: _ventList.length,
                        itemBuilder: (context, index) {
                          final vent = _ventList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.brown,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vent['text'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFF5F5DC),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  vent['time'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFF5F5DC),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
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
