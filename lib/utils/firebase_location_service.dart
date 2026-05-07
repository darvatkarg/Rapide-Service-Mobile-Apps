import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class FirebaseLocationService {
  static final FirebaseLocationService _instance =
      FirebaseLocationService._internal();

  factory FirebaseLocationService() => _instance;

  FirebaseLocationService._internal();

  Timer? _timer;
  bool _isRunning = false;

  Future<void> start(String driverId) async {
    if (_isRunning) return;

    debugPrint(" Firebase location STARTED for driver: $driverId");

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    debugPrint(" Permission status: $permission");

    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      debugPrint("⏱ TIMER TRIGGERED");
      await _sendLocation(driverId);
    });

    _isRunning = true;
  }

  void stop(String driverId) {
    debugPrint("Firebase location STOPPED");

    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    // Mark inactive in Firebase
    FirebaseDatabase.instance.ref("drivers/$driverId").update({
      "isActive": false,
    });
  }

  Future<void> _sendLocation(String driverId) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint(" LOCATION: ${pos.latitude}, ${pos.longitude}");

      await FirebaseDatabase.instance.ref("drivers/$driverId").update({
        "latitude": pos.latitude,
        "longitude": pos.longitude,
        "isActive": true,
        "lastUpdated": DateTime.now().toIso8601String(),
      });

      debugPrint(" SENT TO FIREBASE SUCCESSFULLY");
    } catch (e) {
      debugPrint("FIREBASE ERROR: $e");
    }
  }

  bool get isRunning => _isRunning;
}
