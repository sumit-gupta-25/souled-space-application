import 'package:flutter/material.dart';
import 'package:souled_space_application/ui_blueprint.dart';

class IndiHome extends StatefulWidget {
  const IndiHome({super.key});

  @override
  IndiHomeState createState() => IndiHomeState();
}

class IndiHomeState extends State<IndiHome> {
  @override
  Widget build(BuildContext context) {
    return UiTemplate(
      title: 'Individual Home',

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stress Thermometer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'stress_thermometer');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.thermostat,
                        color: Color(0xFFF5F5DC),
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Stress \nThermometer',
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xFFF5F5DC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Anonymous Venting Wall Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'anonymous_venting_wall');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.visibility_off,
                        color: Color(0xFFF5F5DC),
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Anonymous \nVenting Wall',
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xFFF5F5DC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Journaling Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'myjournals');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.visibility_off,
                        color: Color(0xFFF5F5DC),
                        size: 30,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Journaling',
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xFFF5F5DC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
