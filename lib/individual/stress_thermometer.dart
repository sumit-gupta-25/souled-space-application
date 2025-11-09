import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:souled_space_application/ui_blueprint.dart';

class StressThermometer extends StatefulWidget {
  const StressThermometer({super.key});

  @override
  State<StressThermometer> createState() => _StressThermometerState();
}

class _StressThermometerState extends State<StressThermometer>
    with SingleTickerProviderStateMixin {
  double _stressLevel = 0.0;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _navigateBasedOnLevel() {
    // For now, all levels go to Journaling
    if (_stressLevel > 0 && _stressLevel <= 25) {
      Navigator.pushNamed(context, 'myjournals');
    } else if (_stressLevel > 25 && _stressLevel <= 50) {
      Navigator.pushNamed(context, 'myjournals');
    } else if (_stressLevel > 50 && _stressLevel <= 75) {
      Navigator.pushNamed(context, 'myjournals');
    } else {
      Navigator.pushNamed(context, 'myjournals');
    }
  }

  Color getStressColor(double level) {
    if (level <= 25) return Colors.green;
    if (level <= 50) return Colors.yellow.shade700;
    if (level <= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final stressColor = getStressColor(_stressLevel);

    return UiTemplate(
      title: 'Stress Thermometer',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '"Slide to check your stress level"',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Thermometer Visualization with Wave Animation
            SizedBox(
              height: 320,
              width: 100,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Outer Glass
                  Container(
                    width: 80,
                    height: 300,
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
                          child: const SizedBox(width: 80, height: 300),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Text(
              'Stress Level: ${_stressLevel.toInt()}%',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Slider
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
            ),

            const SizedBox(height: 40),

            // Continue Button
            ElevatedButton(
              onPressed: _navigateBasedOnLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Color(0xFFF5F5DC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🌀 Custom Painter for Wave (Liquid animation)
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
