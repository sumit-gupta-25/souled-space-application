import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MeditationMusicPage extends StatefulWidget {
  const MeditationMusicPage({super.key});

  @override
  State<MeditationMusicPage> createState() => _MeditationMusicPageState();
}

class _MeditationMusicPageState extends State<MeditationMusicPage> {
  final AudioPlayer player = AudioPlayer();

  int currentIndex = 0;
  bool isPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  final List<Map<String, dynamic>> tracks = [
    {
      "title": "Forest Calm",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "color": Colors.green,
      "icon": Icons.park,
      "gradient": [Color(0xFF2E7D32), Color(0xFF81C784)],
    },

    {
      "title": "Deep Relaxation",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
      "color": Color(0xFF6D4C41),
      "icon": Icons.spa,
      "gradient": [Color(0xFF4E342E), Color(0xFFA1887F)],
    },

    {
      "title": "Soft Piano",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
      "color": Colors.black,
      "icon": Icons.piano,
      "gradient": [Colors.black, Colors.grey],
    },

    {
      "title": "Ocean Breathing",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
      "color": Colors.teal,
      "icon": Icons.water,
      "gradient": [Color(0xFF00695C), Color(0xFF4DB6AC)],
    },

    {
      "title": "Night Meditation",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
      "color": Colors.indigo,
      "icon": Icons.nightlight_round,
      "gradient": [Color(0xFF1A237E), Colors.black],
    },
  ];

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    player.onPositionChanged.listen((p) {
      setState(() => position = p);
    });
  }

  Future<void> playMusic() async {
    await player.play(UrlSource(tracks[currentIndex]["url"]));

    setState(() {
      isPlaying = true;
    });
  }

  Future<void> pauseMusic() async {
    await player.pause();

    setState(() {
      isPlaying = false;
    });
  }

  void nextMusic() {
    setState(() {
      if (currentIndex < tracks.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
    });

    playMusic();
  }

  void previousMusic() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = tracks.length - 1;
      }
    });

    playMusic();
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  String formatTime(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString();
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final track = tracks[currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // we add our own button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: track["gradient"],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const SizedBox(height: 20),

              Icon(track["icon"], size: 140, color: Colors.white),

              const SizedBox(height: 20),

              Text(
                track["title"],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                min: 0,
                max:
                    duration.inSeconds.toDouble() == 0
                        ? 1
                        : duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble().clamp(
                  0,
                  duration.inSeconds.toDouble() == 0
                      ? 1
                      : duration.inSeconds.toDouble(),
                ),
                onChanged: (value) async {
                  final pos = Duration(seconds: value.toInt());
                  await player.seek(pos);
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      formatTime(position),
                      style: const TextStyle(color: Colors.white),
                    ),

                    Text(
                      formatTime(duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  IconButton(
                    iconSize: 50,
                    color: Colors.white,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: previousMusic,
                  ),

                  const SizedBox(width: 20),

                  IconButton(
                    iconSize: 80,
                    color: Colors.white,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle : Icons.play_circle,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        pauseMusic();
                      } else {
                        playMusic();
                      }
                    },
                  ),

                  const SizedBox(width: 20),

                  IconButton(
                    iconSize: 50,
                    color: Colors.white,
                    icon: const Icon(Icons.skip_next),
                    onPressed: nextMusic,
                  ),
                ],
              ),

              if (track["title"] == "Night Meditation")
                const Padding(
                  padding: EdgeInsets.only(top: 40),

                  child: Icon(Icons.star, color: Colors.white70, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
