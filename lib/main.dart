import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:souled_space_application/group/group_home.dart';
import 'package:souled_space_application/home.dart';
import 'package:souled_space_application/individual/anonymous_venting_wall.dart';
import 'package:souled_space_application/individual/indi_home.dart';
import 'package:souled_space_application/individual/journaling.dart';
import 'package:souled_space_application/individual/stress_thermometer.dart';
import 'package:souled_space_application/login.dart';
import 'package:souled_space_application/register.dart';
import 'firebase_options.dart';
import 'package:souled_space_application/individual/meditation_music.dart';
import 'package:souled_space_application/individual/breathing_meditation.dart';

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
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',   
      routes: {
        'login': (context) => const MyLogin(),
        'register': (context) => const MyRegister(),
        'home': (context) => const MyHome(),
        'individual': (context) => const IndiHome(),
        'group': (context) => const GroupHome(),
        'stress_thermometer': (context) => const StressThermometer(),
        'anonymous_venting_wall': (context) => const AnonymousVentingWall(),
        'myjournals': (context) => const MyJournals(),
        'meditation_music': (context) => const MeditationMusicPage(),
        'breathing_meditation': (context) => const BreathToRecharge (),
      },
    );
  }
}
