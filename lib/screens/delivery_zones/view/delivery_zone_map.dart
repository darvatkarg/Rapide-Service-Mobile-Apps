import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hyper_local/config/global.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/routing_service.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:hyper_local/config/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryZoneMap extends StatefulWidget {
  final String targetLat;
  final String targetLong;
  final String targetName;
  final String targetAddress;
  final String targetMobile;
  final String targetType; // 'Sender' or 'Receiver'

  const DeliveryZoneMap({
    super.key,
    required this.targetLat,
    required this.targetLong,
    required this.targetName,
    required this.targetAddress,
    required this.targetMobile,
    required this.targetType,
  });

  @override
  State<DeliveryZoneMap> createState() => _DeliveryZoneMapState();
}

class _DeliveryZoneMapState extends State<DeliveryZoneMap> {
  GoogleMapController? _mapController;
  StreamSubscription<DatabaseEvent>? _driverSubscription;

  LatLng? targetLatLng;
  LatLng? driverLatLng;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  BitmapDescriptor? _carIcon;
  final RoutingService _routingService = RoutingService();

  // Tracking info
  double _distanceKm = 0;
  int _etaMinutes = 0;
  bool _isInitialCameraSet = false;

  @override
  void initState() {
    super.initState();

    targetLatLng = LatLng(
      double.parse(widget.targetLat),
      double.parse(widget.targetLong),
    );

    _loadCustomMarker();

    // Initial Target Marker (Sender or Receiver)
    _markers.add(
      Marker(
        markerId: const MarkerId("target"),
        position: targetLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.targetType == 'Sender'
              ? BitmapDescriptor.hueBlue
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(title: widget.targetType),
      ),
    );

    _listenDriverLocation();
  }

  Future<void> _loadCustomMarker() async {
    try {
      final Uint8List markerIcon = await _getBytesFromAsset(
        'assets/images/delivery-boy-car.png',
        80,
      );
      setState(() {
        _carIcon = BitmapDescriptor.fromBytes(markerIcon);
      });
    } catch (e) {
      debugPrint("Error loading car icon: $e");
    }
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    super.dispose();
  }

  bool _followDriver = true;

  void _listenDriverLocation() async {
    String? driverId = await Global.getDriverId();
    if (driverId == null) return;

    _driverSubscription = FirebaseDatabase.instance
        .ref("drivers/$driverId")
        .onValue
        .listen((event) async {
          final data = event.snapshot.value;
          if (data == null) return;

          final map = Map<String, dynamic>.from(data as Map);
          double lat = (map['latitude'] ?? 0).toDouble();
          double lng = (map['longitude'] ?? 0).toDouble();
          double heading = (map['heading'] ?? 0).toDouble();

          if (!mounted) return;

          final newDriverLatLng = LatLng(lat, lng);

          // Update route and ETA
          if (driverLatLng == null ||
              (driverLatLng!.latitude - lat).abs() > 0.0001 ||
              (driverLatLng!.longitude - lng).abs() > 0.0001) {
            _updateRoute(newDriverLatLng);
          }

          setState(() {
            driverLatLng = newDriverLatLng;

            _markers.removeWhere((m) => m.markerId.value == "driver");
            _markers.add(
              Marker(
                markerId: const MarkerId("driver"),
                position: driverLatLng!,
                rotation: heading,
                flat: true,
                anchor: const Offset(0.5, 0.5),
                icon:
                    _carIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
              ),
            );
          });

          // Google Maps style: Center on driver and rotate camera
          if (_followDriver && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: driverLatLng!,
                  zoom: 17,
                  bearing: heading,
                  tilt: 45,
                ),
              ),
            );
          }

          if (!_isInitialCameraSet) {
            _fitBounds();
          }
        });
  }

  Future<void> _updateRoute(LatLng driverPos) async {
    try {
      final points = await _routingService.getRoute(
        ll.LatLng(driverPos.latitude, driverPos.longitude),
        ll.LatLng(targetLatLng!.latitude, targetLatLng!.longitude),
      );

      if (!mounted) return;

      // Calculate real distance from polyline
      double distance = 0;
      for (int i = 0; i < points.length - 1; i++) {
        distance += const ll.Distance().as(
          ll.LengthUnit.Meter,
          points[i],
          points[i + 1],
        );
      }

      setState(() {
        _distanceKm = distance / 1000;
        _etaMinutes =
            (_distanceKm * 3).toInt(); // Simple heuristic: 3 mins per km
        if (_etaMinutes < 1 && _distanceKm > 0) _etaMinutes = 1;

        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
            color: AppColors.primaryColor,
            width: 7,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      });

      // Initial fit after route is loaded
      if (!_isInitialCameraSet) {
        _fitBounds();
        _isInitialCameraSet = true;
      }
    } catch (e) {
      debugPrint("Error updating route: $e");
    }
  }

  void _fitBounds() {
    if (_mapController == null || driverLatLng == null || targetLatLng == null)
      return;

    LatLngBounds bounds;
    if (driverLatLng!.latitude > targetLatLng!.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(
          targetLatLng!.latitude,
          driverLatLng!.longitude < targetLatLng!.longitude
              ? driverLatLng!.longitude
              : targetLatLng!.longitude,
        ),
        northeast: LatLng(
          driverLatLng!.latitude,
          driverLatLng!.longitude > targetLatLng!.longitude
              ? driverLatLng!.longitude
              : targetLatLng!.longitude,
        ),
      );
    } else {
      bounds = LatLngBounds(
        southwest: LatLng(
          driverLatLng!.latitude,
          driverLatLng!.longitude < targetLatLng!.longitude
              ? driverLatLng!.longitude
              : targetLatLng!.longitude,
        ),
        northeast: LatLng(
          targetLatLng!.latitude,
          driverLatLng!.longitude > targetLatLng!.longitude
              ? driverLatLng!.longitude
              : targetLatLng!.longitude,
        ),
      );
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 120));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setMapStyle();
    if (targetLatLng != null) {
      _fitBounds();
    }
  }

  void _setMapStyle() async {}

  @override
  Widget build(BuildContext context) {
    if (targetLatLng == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onCameraMove: (position) {
              // If the user moves the map, stop following
              if (_followDriver) {
                setState(() => _followDriver = false);
              }
            },
            initialCameraPosition: CameraPosition(
              target: targetLatLng!,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              padding: EdgeInsets.only(top: 40.h, left: 16.w, right: 16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  const Text(
                    "Track Your Delivery",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Swiggy Style Info Card
          Positioned(
            bottom: 15.h + MediaQuery.of(context).padding.bottom,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.timer,
                          color: AppColors.primaryColor,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _etaMinutes > 0
                                  ? "$_etaMinutes mins away"
                                  : "Arriving shortly",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _distanceKm > 0
                                  ? "${_distanceKm.toStringAsFixed(1)} km to destination"
                                  : "Reached destination",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color:
                              widget.targetType == 'Sender'
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.targetType == 'Sender'
                              ? Icons.upload_file
                              : Icons.download_done,
                          color:
                              widget.targetType == 'Sender'
                                  ? Colors.blue
                                  : Colors.red,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.targetType}: ${widget.targetName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.targetAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.call, color: Colors.white),
                          onPressed: () async {
                            if (widget.targetMobile.isNotEmpty) {
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: widget.targetMobile,
                              );
                              if (await canLaunchUrl(launchUri)) {
                                await launchUrl(launchUri);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recenter Button
          Positioned(
            bottom: 230.h + MediaQuery.of(context).padding.bottom,
            right: 16.w,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() => _followDriver = true);
                _fitBounds();
              },
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
