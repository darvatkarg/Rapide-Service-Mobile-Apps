import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryZoneMap extends StatefulWidget {
  final String rcLat;
  final String rcLong;
  final String driverId;

  const DeliveryZoneMap({
    super.key,
    required this.rcLat,
    required this.rcLong,
    required this.driverId,
  });

  @override
  State<DeliveryZoneMap> createState() => _DeliveryZoneMapState();
}

class _DeliveryZoneMapState extends State<DeliveryZoneMap> {
  GoogleMapController? _mapController;
  StreamSubscription<DatabaseEvent>? _driverSubscription;

  LatLng? receiverLatLng;
  LatLng? driverLatLng;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();

    debugPrint("========== MAP SCREEN OPEN ==========");
    debugPrint("📦 Driver ID: ${widget.driverId}");
    debugPrint("📍 Raw Receiver Lat: ${widget.rcLat}");
    debugPrint("📍 Raw Receiver Long: ${widget.rcLong}");

    try {
      receiverLatLng = LatLng(
        double.parse(widget.rcLat),
        double.parse(widget.rcLong),
      );

      debugPrint("✅ Parsed Receiver LatLng: $receiverLatLng");
    } catch (e) {
      debugPrint("❌ Error parsing receiver lat/lng: $e");
    }

    // Add receiver marker
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
    _driverSubscription?.cancel();
    super.dispose();
  }

  // 🔥 FIREBASE LISTENER
  void _listenDriverLocation() {
    if (widget.driverId.isEmpty) {
      debugPrint("❌ Driver ID is EMPTY → Cannot fetch location");
      return;
    }

    final ref = FirebaseDatabase.instance.ref("drivers/${widget.driverId}");

    debugPrint("👂 Listening to Firebase path: drivers/${widget.driverId}");

    _driverSubscription = ref.onValue.listen((event) {
      debugPrint("📡 Firebase event received");

      final data = event.snapshot.value;

      if (data == null) {
        debugPrint("⚠️ Firebase returned NULL data");
        return;
      }

      debugPrint("📦 Raw Firebase Data: $data");

      try {
        final map = Map<String, dynamic>.from(data as Map);

        final latData = map['latitude'];
        final lngData = map['longitude'];

        if (latData == null || lngData == null) {
          debugPrint("❌ Firebase latitude/longitude is NULL");
          return;
        }

        double lat = double.tryParse(latData.toString()) ?? 0;
        double lng = double.tryParse(lngData.toString()) ?? 0;

        if (lat == 0 || lng == 0) {
          debugPrint("❌ Invalid driver coordinates: $lat, $lng");
          return;
        }

        debugPrint("🚴 Driver LIVE LatLng: $lat, $lng");

        if (!mounted) return;

        setState(() {
          driverLatLng = LatLng(lat, lng);

          _markers.clear();
          _polylines.clear();

          // Receiver marker
          _markers.add(
            Marker(
              markerId: const MarkerId("receiver"),
              position: receiverLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          );

          // Driver marker
          _markers.add(
            Marker(
              markerId: const MarkerId("driver"),
              position: driverLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );

          // Line
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: [driverLatLng!, receiverLatLng!],
              color: Colors.blue,
              width: 5,
            ),
          );
        });

        debugPrint("✅ Map updated with new driver location");

        _fitMapToBounds();
      } catch (e) {
        debugPrint("❌ Error parsing Firebase data: $e");
      }
    }, onError: (error) {
      debugPrint("❌ Firebase LISTENER ERROR: $error");
    });
  }

  void _fitMapToBounds() {
    if (_mapController == null ||
        driverLatLng == null ||
        receiverLatLng == null) {
      debugPrint("⚠️ Cannot fit map → missing data");
      return;
    }

    debugPrint("🗺 Fitting camera correctly");

    final southwestLat = driverLatLng!.latitude < receiverLatLng!.latitude
        ? driverLatLng!.latitude
        : receiverLatLng!.latitude;

    final southwestLng = driverLatLng!.longitude < receiverLatLng!.longitude
        ? driverLatLng!.longitude
        : receiverLatLng!.longitude;

    final northeastLat = driverLatLng!.latitude > receiverLatLng!.latitude
        ? driverLatLng!.latitude
        : receiverLatLng!.latitude;

    final northeastLng = driverLatLng!.longitude > receiverLatLng!.longitude
        ? driverLatLng!.longitude
        : receiverLatLng!.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    debugPrint("🗺 Google Map CREATED");
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
