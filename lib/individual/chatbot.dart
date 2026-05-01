import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isTyping = false;

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      isTyping = true;
    });

    _controller.clear();

    final reply = await ChatbotService.sendMessage(text);

    setState(() {
      isTyping = false;
      messages.add({"role": "bot", "text": reply});
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget buildMessage(Map<String, String> msg) {
    final isUser = msg["role"] == "user";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.brown,
              child: Icon(
                Icons.wb_sunny_outlined,
                size: 14,
                color: Colors.white,
              ),
            ),
          if (!isUser) const SizedBox(width: 6),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? Colors.brown.shade400
                        : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                msg["text"]!,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget typingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.brown,
            child: Icon(Icons.favorite, size: 14, color: Colors.white),
          ),
          SizedBox(width: 8),
          Text("Typing...", style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    messages.add({
      "role": "bot",
      "text": "Hey, I'm here for you. How are you feeling today?",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      appBar: AppBar(
        title: const Text(
          "Clarity Bot",
          style: TextStyle(
            color: Color(0xFFF4F1EA),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
        iconTheme: const IconThemeData(color: Color(0xFFF4F1EA)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i < messages.length) {
                  return buildMessage(messages[i]);
                } else {
                  return typingIndicator();
                }
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F1EA),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Talk to me...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.brown,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
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
