import 'package:flutter/material.dart';
import 'dart:math';

class CBTReflectionPage extends StatefulWidget {
  const CBTReflectionPage({super.key});

  @override
  State<CBTReflectionPage> createState() => _CBTReflectionPageState();
}

class _CBTReflectionPageState extends State<CBTReflectionPage>
    with TickerProviderStateMixin {
  Map<String, bool> completed = {
    "Situation": false,
    "Thoughts": false,
    "Emotions": false,
    "Body": false,
    "Behavior": false,
  };

  final situation = TextEditingController();
  final thoughts = TextEditingController();
  final emotions = TextEditingController();
  final body = TextEditingController();
  final behavior = TextEditingController();

  late AnimationController sweepController;

  bool showAffirmation = false;

  List<String> affirmations = [
    "You are stronger than this moment.",
    "Your thoughts are not your identity.",
    "Growth begins with awareness.",
    "You handled today better than you think.",
    "Every reflection builds resilience.",
  ];

  @override
  void initState() {
    super.initState();

    sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void transform(String key) {
    setState(() {
      completed[key] = true;
    });

    sweepController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 800), () {
      bool allDone = completed.values.every((e) => e == true);

      if (allDone) {
        setState(() {
          showAffirmation = true;
        });
      }
    });
  }

  /// UPDATED CIRCLE WITH GLOW
  Widget circle(String label, Color color, double top, double left) {
    bool done = completed[label]!;

    return Positioned(
      top: top,
      left: left,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          color: done ? color.withOpacity(.3) : Colors.white,

          /// glow effect
          boxShadow:
              done
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.7),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ]
                  : [],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget questionCard(
    String title,
    String question,
    TextEditingController controller,
    Color color,
    String keyName,
  ) {
    if (completed[keyName] == true) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: sweepController,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(
            0,
            completed[keyName]! ? -200 * sweepController.value : 0,
          ),

          child: Opacity(
            opacity: completed[keyName]! ? 1 - sweepController.value : 1,

            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(.25), Colors.white],
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(question),

                    const SizedBox(height: 12),

                    TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Write your reflection...",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => transform(keyName),
                        child: const Text("Transform"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // we add our own button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Reframe & Rise",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  fontFamily: "serif",
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Transform thoughts into clarity using CBT reflection",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    circle("Situation", Colors.green, 0, 140),

                    circle("Thoughts", Colors.orange, 90, 260),

                    circle("Body", Colors.red, 90, 20),

                    circle("Emotions", Colors.blue, 180, 260),

                    circle("Behavior", Colors.purple, 180, 140),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              questionCard(
                "Situation",
                "What situation triggered your stress today?",
                situation,
                Colors.green,
                "Situation",
              ),

              questionCard(
                "Thoughts",
                "What thoughts went through your mind in that moment?",
                thoughts,
                Colors.blue,
                "Thoughts",
              ),

              questionCard(
                "Emotions",
                "What emotions did you feel?",
                emotions,
                Colors.orange,
                "Emotions",
              ),

              questionCard(
                "Body Sensations",
                "How did your body react? (heartbeat, tension, fatigue)",
                body,
                Colors.red,
                "Body",
              ),

              questionCard(
                "Behavior",
                "What did you do? How did you react?",
                behavior,
                Colors.purple,
                "Behavior",
              ),

              const SizedBox(height: 30),

              if (showAffirmation)
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDFF5E1), Color(0xFFFFFFFF)],
                      ),
                    ),

                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: Colors.green,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Reflection Complete",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          affirmations[Random().nextInt(affirmations.length)],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
