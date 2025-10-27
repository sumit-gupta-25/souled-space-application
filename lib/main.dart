import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
=======
import 'package:souled_space_application/home.dart';
import 'package:souled_space_application/login.dart';
import 'package:souled_space_application/register.dart';
>>>>>>> 83243f9a2dd2f9761b1075ccf31f1494b18e889d
import 'package:souled_space_application/group/group_home.dart';
import 'package:souled_space_application/home.dart';
import 'package:souled_space_application/individual/anonymous_venting_wall.dart';
<<<<<<< HEAD
import 'package:souled_space_application/individual/indi_home.dart';
import 'package:souled_space_application/individual/journaling.dart';
import 'package:souled_space_application/individual/stress_thermometer.dart';
import 'package:souled_space_application/login.dart';
import 'package:souled_space_application/register.dart';
import 'firebase_options.dart'; // 👈 auto-generated file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase before running the app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
=======
import 'package:souled_space_application/individual/stress_thermometer.dart';
import 'package:souled_space_application/individual/indi_home.dart';
import 'package:souled_space_application/individual/journaling.dart';
>>>>>>> 83243f9a2dd2f9761b1075ccf31f1494b18e889d

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      initialRoute: 'login',
      routes: {
        'login': (context) => const MyLogin(),
        'register': (context) => const MyRegister(),
        'home': (context) => const MyHome(),
        'individual': (context) => const IndiHome(),
        'group': (context) => const GroupHome(),
        'stress_thermometer': (context) => const StressThermometer(),
        'anonymous_venting_wall': (context) => const AnonymousVentingWall(),
        'journaling': (context) => const Journaling(),
        'myjournals': (context) => const MyJournals(),
=======
      home: MyLogin(),
      routes: {
        'register': (context) => MyRegister(),
        'login': (context) => MyLogin(),
        'home': (context) => MyHome(),
        'individual': (context) => IndiHome(),
        'stress_thermometer': (context) => StressThermometer(),
        'journaling': (context) => Journaling(),
        'myjournals': (context) => MyJournals(),
        'anonymous_venting_wall': (context) => AnonymousVentingWall(),
        'community': (context) => GroupHome(),
>>>>>>> 83243f9a2dd2f9761b1075ccf31f1494b18e889d
      },
    );
  }
}
