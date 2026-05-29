import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:souled_space_application/main.dart';
import 'social_media_service.dart';
import 'stress_detection_service.dart';

class SocialSyncHandler {
  static final SocialSyncHandler _instance = SocialSyncHandler._internal();
  factory SocialSyncHandler() => _instance;
  SocialSyncHandler._internal();

  final SocialMediaService _scraper = SocialMediaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // The ONLY state variables for the entire app's stress level
  final ValueNotifier<Map<String, dynamic>> syncNotifier = ValueNotifier({'level': 0.0});

  final String _currentMasterTimestamp = '2000-01-01 00:00:00';

  String dbTime = "", instaTime = "";
  double dbLevel = 0.0, instaLevel = 0.0;

  /// 2. SOURCE: Instagram Scraper
  Future<void> runSocialSync(String timeDb, instaId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final List<dynamic> postsData = await _scraper.fetchInstagramPosts(instaId);
    if (postsData.isEmpty) return;
    for (var post in postsData) {
      final String platformTime = post['timestamp'] ?? '2000-01-01 00:00:00';
      final String postText = post['text'] ?? "";
      // Optimization: Don't even call the ML model if the post is old
      if (platformTime.compareTo(_currentMasterTimestamp) >= 0) {
        final result = await StressDetectionService.analyzeText(postText);
        if (result != null && result['success'] == true) {
          double level = (result['stress_level'] as num).toDouble();
          //_processIncomingData(level, platformTime, isSocialMedia: true);
          instaLevel = level;
          instaTime = platformTime;
          dbTime = timeDb;
          _processFinalData(dbTime, instaTime);
        }
      }
    }
  }

  void startDatabaseListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _database
        .child('users')
        .child(user.uid)
        .child('instaId')
        .get()
        .then((snapshot) {
          String? instaId = snapshot.exists ? snapshot.value as String : null;
          debugPrint("Fetched instaId for sync: $instaId");

          // Listen to the latest vent
          _database.child('vents').orderByChild('uid').equalTo(user.uid).limitToLast(1).onValue.listen((event) {
            if (event.snapshot.exists && event.snapshot.value != null) {
              try {
                final data = event.snapshot.value as Map<dynamic, dynamic>;
                final latestVent = data.values.first as Map<dynamic, dynamic>;

                // FIX: Check if it's a number first. If it's a String ("Unable to detect"), default to 0.0
                final rawLevel = latestVent['stress_level'];
                if (rawLevel is num) {
                  dbLevel = rawLevel.toDouble();
                } else {
                  dbLevel = 0.0; // Safe fallback for text values
                }

                dbTime = latestVent['time'] as String;

                debugPrint("dbLevel is: $dbLevel");
                debugPrint("dbTime is: $dbTime");

                runSocialSync(dbTime, instaId);
              } catch (e) {
                debugPrint("Parsing error: $e");
              }
            }
          });
        })
        .catchError((error) {
          debugPrint("Error: $error");
        });
  }

  void _processFinalData(String timeDb, timeInsta) {
    DateTime d1 = DateTime.parse(timeDb);
    DateTime d2 = DateTime.parse(timeInsta);
    if (d1.isAfter(d2)) {
      syncNotifier.value = {'level': dbLevel};
      _showGlobalAlert(dbLevel);
    } else if (d2.isAfter(d1)) {
      syncNotifier.value = {'level': instaLevel};
      _showGlobalAlert(instaLevel);
    }
  }

  void _showGlobalAlert(double level) {
    scaffoldMessengerKey.currentState?.clearSnackBars(); // Clear existing to avoid stacking
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Current Stress Level: ${level.toInt()}%'),
        backgroundColor: Colors.brown,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showWaitingSnackbar() {
    // Wait for the UI to finish its current build cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text("Please wait while we detect your stress levels"),
          backgroundColor: Colors.brown,
          duration: const Duration(seconds: 120),
        ),
      );
    });
  }
}
