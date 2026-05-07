import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hyper_local/config/global.dart';

class DeliveryZoneMap extends StatefulWidget {
  final String rcLat;
  final String rcLong;

  const DeliveryZoneMap({super.key, required this.rcLat, required this.rcLong});

  @override
  State<DeliveryZoneMap> createState() => _DeliveryZoneMapState();
}

class _DeliveryZoneMapState extends State<DeliveryZoneMap> {
  GoogleMapController? _mapController;
  StreamSubscription<DatabaseEvent>? _driverSubscription;

  LatLng? receiverLatLng;
  LatLng? driverLatLng;
  final Set<Polyline> _polylines = {};

  final Set<Marker> _markers = {};

 @override
void initState() {
  super.initState();

  receiverLatLng = LatLng(
    double.parse(widget.rcLat),
    double.parse(widget.rcLong),
  );

  debugPrint("📍 Receiver Location: $receiverLatLng");

  // ✅ ADD RECEIVER MARKER IMMEDIATELY
  _markers.add(
    Marker(
      markerId: const MarkerId("receiver"),
      position: receiverLatLng!,
      infoWindow: const InfoWindow(title: "Receiver"),
    ),
  );

  _listenDriverLocation();
}

  @override
  void dispose() {
    debugPrint("🛑 Disposing map screen");

    _driverSubscription?.cancel(); // 🔥 VERY IMPORTANT

    super.dispose();
  }

  void _listenDriverLocation() async {
    String? driverId = await Global.getDriverId();

    if (driverId == null) {
      debugPrint("❌ Driver ID is NULL");
      return;
    }

    debugPrint("👂 Listening to Firebase for driver: $driverId");

    _driverSubscription = FirebaseDatabase.instance
        .ref("drivers/$driverId")
        .onValue
        .listen((event) {
          final data = event.snapshot.value;

          if (data == null) return;

          final map = Map<String, dynamic>.from(data as Map);

          double lat = (map['latitude'] ?? 0).toDouble();
          double lng = (map['longitude'] ?? 0).toDouble();

          debugPrint("🚴 Driver Location: $lat, $lng");

          // ✅ FIX: check mounted
          if (!mounted) return;

          setState(() {
            driverLatLng = LatLng(lat, lng);

            _markers.clear();
            _polylines.clear();

            _markers.add(
              Marker(
                markerId: const MarkerId("receiver"),
                position: receiverLatLng!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            );

            _markers.add(
              Marker(
                markerId: const MarkerId("driver"),
                position: driverLatLng!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
            );

            _polylines.add(
              Polyline(
                polylineId: const PolylineId("route"),
                points: [driverLatLng!, receiverLatLng!],
                color: Colors.blue,
                width: 5,
              ),
            );
          });
        });
  }

void _onMapCreated(GoogleMapController controller) {
  _mapController = controller;

  debugPrint("🗺 Map created");

  // Move camera to receiver initially
  if (receiverLatLng != null) {
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(receiverLatLng!, 14),
    );
  }
}

  @override
Widget build(BuildContext context) {
  if (receiverLatLng == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(title: const Text("Live Tracking")),
    body: GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: receiverLatLng!,
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
    ),
  );
}
}
