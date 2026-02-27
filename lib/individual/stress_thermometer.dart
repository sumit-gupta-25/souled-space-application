import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:souled_space_application/ui_blueprint.dart';
import 'dart:async';

class StressThermometer extends StatefulWidget {
  const StressThermometer({super.key});

  @override
  State<StressThermometer> createState() => _StressThermometerState();
}

class _StressThermometerState extends State<StressThermometer>
    with SingleTickerProviderStateMixin {
  double _stressLevel = 0.0;
  late AnimationController _waveController;
  late StreamSubscription<DatabaseEvent> _ventSubscription;

  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  double? _lastShownLevel;

  bool _autoUpdateEnabled = true;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Listen to vents and auto-update stress level
    _listenToLatestVent();
  }

  void _listenToLatestVent() {
    _ventSubscription = _database.child('vents').limitToLast(1).onValue.listen((
      DatabaseEvent event,
    ) {
      if (_autoUpdateEnabled && event.snapshot.exists) {
        final data = event.snapshot.value;
        if (data != null) {
          final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;

          map.forEach((key, value) {
            final userId = _auth.currentUser?.uid;

            // Only update if the latest post is from current user
            if (value['uid'] == userId) {
              final stressLevel = (value['stress_level'] ?? 0.0).toDouble();

              // Prevent duplicate popup for same stress level
              if (_lastShownLevel == stressLevel) return;

              if (!mounted) return;

              setState(() {
                _stressLevel = stressLevel;
              });

              _lastShownLevel = stressLevel;

              if (!mounted) return;

              _showSupportPopup(stressLevel);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'We’ve updated your stress check-in. Take a deep breath.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _ventSubscription.cancel();
    _waveController.dispose();
    super.dispose();
  }

  Map<String, String> getRecommendedAction(double level) {
    if (level <= 25) {
      return {"label": "Write in My Journal", "route": "myjournals"};
    } else if (level <= 50) {
      return {
        "label": "Listen to Something Calming",
        "route": "meditation_music",
      };
    } else if (level <= 75) {
      return {
        "label": "Take a Moment to Breathe",
        "route": "breathing_meditation",
      };
    } else {
      return {"label": "Gently Reflect with CBT", "route": "cbt_reflection"};
    }
  }

  void _showSupportPopup(double level) {
    final action = getRecommendedAction(level);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: const Color(0xFFFDF6EC),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "A Gentle Check-In",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  getPopupMessage(level),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.brown,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: const Color(0xFFF5F5DC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, action["route"]!);
                      },
                      child: Text(
                        action["label"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Stay Here",
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color getStressColor(double level) {
    if (level <= 25) return Colors.green;
    if (level <= 50) return Colors.yellow.shade700;
    if (level <= 75) return Colors.orange;
    return Colors.red;
  }

  String getStressDescription(double level) {
    if (level <= 25) return 'Calm & Relaxed';
    if (level <= 50) return 'Slightly Tense';
    if (level <= 75) return 'Feeling Stressed';
    return 'Overwhelmed – Take It Slow';
  }

  String getPopupMessage(double level) {
    if (level <= 25) {
      return "You’re feeling calm and grounded 🌿\n\nThis is a beautiful space to reflect. Consider journaling to preserve this clarity and positive energy.";
    } else if (level <= 50) {
      return "There’s a little tension present and that’s completely okay.\n\nA short relaxing meditation could help you gently unwind and reset.";
    } else if (level <= 75) {
      return "You’re carrying noticeable stress right now.\n\nLet’s pause together. A guided breathing exercise can help your body settle and regain balance.";
    } else {
      return "It feels overwhelming right now and that’s valid.\n\nA CBT reflection can help you untangle these thoughts and regain a sense of control. You don’t have to face this alone.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final stressColor = getStressColor(_stressLevel);

    return UiTemplate(
      title: 'Stress Thermometer',
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '"How You’re Feeling Right Now"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Auto-update toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Live Stress Updates: ',
                      style: TextStyle(color: Colors.brown, fontSize: 16),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _autoUpdateEnabled,
                        onChanged: (value) {
                          setState(() => _autoUpdateEnabled = value);
                        },
                        activeThumbColor: Colors.brown,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Thermometer Visualization with Wave Animation
                SizedBox(
                  height: 280,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Outer Glass
                      Container(
                        width: 80,
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.brown.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.brown, width: 3),
                        ),
                      ),

                      // Animated Wave (Liquid Effect)
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CustomPaint(
                              painter: _WavePainter(
                                animationValue: _waveController.value,
                                fillPercent: _stressLevel / 100,
                                color: stressColor,
                              ),
                              child: const SizedBox(width: 80, height: 260),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                Text(
                  'Stress Level: ${_stressLevel.toInt()}%',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  getStressDescription(_stressLevel),
                  style: TextStyle(
                    fontSize: 14,
                    color: getStressColor(_stressLevel),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 15),

                // Manual Slider
                Column(
                  children: [
                    const Text(
                      'Manual Adjustment:',
                      style: TextStyle(color: Colors.brown, fontSize: 14),
                    ),
                    Slider(
                      value: _stressLevel,
                      min: 0,
                      max: 100,
                      activeColor: Colors.brown,
                      inactiveColor: Colors.brown.withValues(alpha: 0.3),
                      divisions: 100,
                      label: '${_stressLevel.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _stressLevel = value;
                        });
                      },
                      onChangeEnd: (value) {
                        if (!_autoUpdateEnabled) {
                          _showSupportPopup(value);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Wave (Liquid animation)
class _WavePainter extends CustomPainter {
  final double animationValue;
  final double fillPercent;
  final Color color;

  _WavePainter({
    required this.animationValue,
    required this.fillPercent,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.8);
    final path = Path();

    double waveHeight = 8;
    double baseHeight = size.height * (1 - fillPercent);

    for (double i = 0; i <= size.width; i++) {
      double dx = i;
      double dy =
          baseHeight +
          math.sin(
                (i / size.width * 2 * math.pi) + animationValue * 2 * math.pi,
              ) *
              waveHeight;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
