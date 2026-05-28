import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:souled_space_application/group/group_home.dart';
import 'package:souled_space_application/home.dart';
import 'package:souled_space_application/individual/journaling.dart';
import 'package:souled_space_application/individual/stress_thermometer.dart';
import 'package:souled_space_application/login.dart';
import 'package:souled_space_application/register.dart';
import 'firebase_options.dart';
import 'package:souled_space_application/individual/meditation_music.dart';
import 'package:souled_space_application/individual/breathing_meditation.dart';
import 'package:souled_space_application/individual/cbt_reflection.dart';
import 'package:souled_space_application/individual/profile.dart';
import 'package:souled_space_application/individual/chatbot.dart';
import 'package:souled_space_application/splash_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash',
      routes: {
        'splash': (context) => const SplashScreen(),
        'login': (context) => const MyLogin(),
        'register': (context) => const MyRegister(),
        'home': (context) => const MyHome(),
        'group': (context) => const GroupHome(),
        'stress_thermometer': (context) => const StressThermometer(),
        'myjournals': (context) => const MyJournals(),
        'meditation_music': (context) => const MeditationMusicPage(),
        'breathing_meditation': (context) => const BreathToRecharge(),
        'cbt_reflection': (context) => const CBTReflectionPage(),
        'profile': (context) => const ProfilePage(),
        'chatbot': (context) => const ChatbotPage(),
      },
    );
  }
}
