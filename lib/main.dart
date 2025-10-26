import 'package:flutter/material.dart';
import 'package:souled_space_application/home.dart';
import 'package:souled_space_application/login.dart';
import 'package:souled_space_application/register.dart';
import 'package:souled_space_application/group/group_home.dart';
import 'package:souled_space_application/individual/anonymous_venting_wall.dart';
import 'package:souled_space_application/individual/stress_thermometer.dart';
import 'package:souled_space_application/individual/indi_home.dart';
import 'package:souled_space_application/individual/journaling.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      },
    );
  }
}
