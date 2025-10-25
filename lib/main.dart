import 'package:flutter/material.dart';
import 'package:souled_space_application/group/group_home.dart';
import 'package:souled_space_application/individual/anonymous_venting_wall.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: GroupHome());
  }
}
