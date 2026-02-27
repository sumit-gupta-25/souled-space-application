import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BreathToRecharge extends StatefulWidget {
  const BreathToRecharge({super.key});

  @override
  State<BreathToRecharge> createState() => _BreathToRechargeState();
}

class _BreathToRechargeState extends State<BreathToRecharge>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final player = AudioPlayer();

  bool holdMode = false;
  bool soundOn = true;

  String phase = "Inhale";

  int secondsLeft = 600; // 10 minutes
  Timer? timer;

  final rainSound =
      "https://cdn.pixabay.com/download/audio/2021/09/06/audio_48b5b3a2c3.mp3";

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: .7,
      upperBound: 1.2,
    )..addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (holdMode) {
          setState(() => phase = "Hold");
          await Future.delayed(const Duration(seconds: 3));
        }

        setState(() => phase = "Exhale");
        controller.reverse();
      }

      if (status == AnimationStatus.dismissed) {
        setState(() => phase = "Inhale");
        controller.forward();
      }
    });

    controller.forward();
    startTimer();
    startRain();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsLeft > 0) {
        setState(() => secondsLeft--);
      }
    });
  }

  void addFiveMinutes() {
    setState(() => secondsLeft += 300);
  }

  void restart() {
    setState(() {
      secondsLeft = 600;
      phase = "Inhale";
    });

    controller.reset();
    controller.forward();
  }

  void toggleMode() {
    setState(() => holdMode = !holdMode);
  }

  void startRain() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(UrlSource(rainSound));
  }

  void toggleSound() async {
    if (soundOn) {
      await player.pause();
    } else {
      await player.resume();
    }

    setState(() => soundOn = !soundOn);
  }

  String format(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Color bgColor() {
    if (phase == "Inhale") {
      return const Color(0xFFE6F4F1);
    }

    if (phase == "Exhale") {
      return const Color(0xFFF3E8FF);
    }

    return const Color(0xFFFFF3E0);
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor(),
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

      backgroundColor: bgColor(),

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(soundOn ? Icons.volume_up : Icons.volume_off),
                  onPressed: toggleSound,
                ),

                const SizedBox(width: 10),
              ],
            ),

            const Text(
              "Breath to Recharge",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Text(phase, style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 15),

            Text(format(secondsLeft), style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 50),

            Stack(
              alignment: Alignment.center,
              children: [
                // ripple waves
                ...List.generate(
                  3,
                  (i) => AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      double scale = controller.value + (i * .2);

                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(.3),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // breathing circle
                AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: controller.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Colors.white, Color(0xFFB2DFDB)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 40,
                              color: Colors.white.withOpacity(.6),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: restart,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Restart"),
                ),

                const SizedBox(width: 15),

                ElevatedButton.icon(
                  onPressed: addFiveMinutes,
                  icon: const Icon(Icons.add),
                  label: const Text("+5 mins"),
                ),

                const SizedBox(width: 15),

                ElevatedButton.icon(
                  onPressed: toggleMode,
                  icon: const Icon(Icons.air),
                  label: Text(holdMode ? "Normal Mode" : "Hold Mode"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
