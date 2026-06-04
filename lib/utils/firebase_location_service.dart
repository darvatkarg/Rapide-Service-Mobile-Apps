import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class FirebaseLocationService {
  static final FirebaseLocationService _instance =
      FirebaseLocationService._internal();

  factory FirebaseLocationService() => _instance;

  FirebaseLocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  bool _isRunning = false;

  Future<void> start(String driverId) async {
    if (_isRunning) return;

    debugPrint("🚀 Firebase location STARTED for driver: $driverId");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Use stream for smoother real-time updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position pos) {
      _updateFirebase(driverId, pos);
    });

    _isRunning = true;
  }

  void stop(String driverId) {
    debugPrint("🛑 Firebase location STOPPED");

    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isRunning = false;

    FirebaseDatabase.instance.ref("drivers/$driverId").update({
      "isActive": false,
    });
  }

  Future<void> _updateFirebase(String driverId, Position pos) async {
    try {
      debugPrint("📍 LOCATION: ${pos.latitude}, ${pos.longitude}");

      await FirebaseDatabase.instance.ref("drivers/$driverId").update({
        "latitude": pos.latitude,
        "longitude": pos.longitude,
        "heading": pos.heading,
        "speed": pos.speed,
        "isActive": true,
        "lastUpdated": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("❌ FIREBASE ERROR: $e");
    }
  }

  bool get isRunning => _isRunning;
}
