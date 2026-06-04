// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/colors.dart';
import '../../../../../config/theme_bloc.dart';
import '../../../model/return_orders_list_model.dart';
import '../../../../../utils/widgets/custom_button.dart';
import '../../../../../utils/widgets/custom_text.dart';
import '../../../../../utils/widgets/custom_appbar_without_navbar.dart';
import 'package:go_router/go_router.dart';
import '../../../../../utils/widgets/toast_message.dart';
import '../store_pickup_route/services/location_service.dart';
import '../../../../../services/routing_service.dart';

class PickupOrderMapPage extends StatefulWidget {
  final Pickups pickup;
  final String locationType; // 'customer' or 'seller'

  const PickupOrderMapPage({
    super.key,
    required this.pickup,
    this.locationType = 'customer',
  });

  @override
  State<PickupOrderMapPage> createState() => _PickupOrderMapPageState();
}

class _PickupOrderMapPageState extends State<PickupOrderMapPage> {
  late MapController _mapController;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  bool _isLoadingLocation = true;
  bool _isExpanded = true;

  // Current stage of pickup process
  // 0 = heading to customer, 1 = at customer (confirm pickup), 2 = heading to store
  int _currentStage = 0;
  final RoutingService _routingService = RoutingService();
  List<LatLng> _routePoints = [];
  Timer? _routeUpdateTimer;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _isLoadingLocation) {
        _setFallbackLocation();
      }
    });

    _startLiveTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _routeUpdateTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startLiveTracking() async {
    // Initial location fetch
    await _getCurrentLocation();

    // Start listening for updates
    _locationSubscription = LocationService.getLocationStream().listen((
      locationData,
    ) {
      if (!mounted) return;

      final oldLocation = _currentLocation;
      setState(() {
        _currentLocation = locationData;
        _isLoadingLocation = false;
      });

      // Update route if location changed significantly or first time
      if (oldLocation == null ||
          (oldLocation.latitude! - locationData.latitude!).abs() > 0.0001 ||
          (oldLocation.longitude! - locationData.longitude!).abs() > 0.0001) {
        _updateRoute();
      }
    });
  }

  Future<void> _updateRoute() async {
    if (_currentLocation == null) return;

    final start = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );
    LatLng? end;

    if (widget.pickup.deliveryRoute?.routeDetails != null &&
        widget.pickup.deliveryRoute!.routeDetails!.isNotEmpty) {
      final targetLocation =
          _currentStage == 0
              ? widget.pickup.deliveryRoute!.routeDetails![0]
              : widget.pickup.deliveryRoute!.routeDetails!.last;

      if (targetLocation.latitude != null && targetLocation.longitude != null) {
        end = LatLng(targetLocation.latitude!, targetLocation.longitude!);
      }
    }

    if (end != null) {
      final points = await _routingService.getRoute(start, end);
      if (mounted) {
        setState(() {
          _routePoints = points;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _setFallbackLocation();
          return;
        }
      }

      PermissionStatus permissionGranted;
      try {
        permissionGranted = await Future.microtask(
          () async => await location.hasPermission(),
        );
      } catch (e) {
        _setFallbackLocation();
        return;
      }

      if (permissionGranted == PermissionStatus.denied) {
        try {
          permissionGranted = await Future.microtask(
            () async => await location.requestPermission(),
          );
          if (permissionGranted != PermissionStatus.granted) {
            _setFallbackLocation();
            return;
          }
        } catch (e) {
          _setFallbackLocation();
          return;
        }
      }

      final locationData = await location.getLocation().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      setState(() {
        _currentLocation = locationData;
        _isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToAllPoints());
    } catch (e) {
      _setFallbackLocation();
    }
  }

  void _setFallbackLocation() {
    setState(() {
      // Use destination address coordinates as fallback location
      final destination = LocationService.getDestinationLocation(
        widget.pickup.deliveryRoute?.routeDetails,
      );
      double fallbackLat = destination.latitude;
      double fallbackLng = destination.longitude;

      _currentLocation = LocationData.fromMap({
        'latitude': fallbackLat,
        'longitude': fallbackLng,
      });
      _isLoadingLocation = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToAllPoints());
  }

  void _recenterMap() {
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        15.0,
      );
    }
  }

  void _fitMapToAllPoints() {
    if (_currentLocation == null) return;

    final List<LatLng> allPoints = [
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
    ];

    // Add customer location (first item in route_details)
    if (widget.pickup.deliveryRoute?.routeDetails != null &&
        widget.pickup.deliveryRoute!.routeDetails!.isNotEmpty) {
      final customerLocation = widget.pickup.deliveryRoute!.routeDetails![0];

      if (customerLocation.latitude != null &&
          customerLocation.longitude != null) {
        final customerPoint = LatLng(
          customerLocation.latitude!,
          customerLocation.longitude!,
        );
        allPoints.add(customerPoint);
      }

      // Add store location (last item in route_details if different from customer)
      if (widget.pickup.deliveryRoute!.routeDetails!.length > 1) {
        final storeLocation = widget.pickup.deliveryRoute!.routeDetails!.last;

        if (storeLocation.latitude != null && storeLocation.longitude != null) {
          final storePoint = LatLng(
            storeLocation.latitude!,
            storeLocation.longitude!,
          );

          // Only add if different from customer location
          if ((storePoint.latitude - allPoints[1].latitude).abs() > 0.0001 ||
              (storePoint.longitude - allPoints[1].longitude).abs() > 0.0001) {
            allPoints.add(storePoint);
          }
        }
      }
    }

    if (allPoints.length >= 2) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50)),
      );
    }
  }

  LatLng _getCurrentLocationLatLng() {
    if (_currentLocation != null) {
      return LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    }
    // Use destination as final fallback
    return LocationService.getDestinationLocation(
      widget.pickup.deliveryRoute?.routeDetails,
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Current location marker (Vehicle Icon)
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          width: 50.w,
          height: 50.h,
          child: Transform.rotate(
            angle: (_currentLocation!.heading ?? 0) * (3.14159 / 180),
            child: Image.asset(
              'assets/images/delivery-boy-car.png',
              width: 50.w,
              height: 50.h,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.w),
                    ),
                    child: Icon(
                      Icons.motorcycle,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    // Customer location marker (where we pick from)
    if (widget.pickup.deliveryRoute?.routeDetails != null &&
        widget.pickup.deliveryRoute!.routeDetails!.isNotEmpty) {
      final customerLocation = widget.pickup.deliveryRoute!.routeDetails![0];

      if (customerLocation.latitude != null &&
          customerLocation.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(
              customerLocation.latitude!,
              customerLocation.longitude!,
            ),
            width: 45.w,
            height: 45.h,
            child: Container(
              decoration: BoxDecoration(
                color: _currentStage >= 1 ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_pin_circle,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        );
      }

      // Store location marker (where we return to)
      if (widget.pickup.deliveryRoute!.routeDetails!.length > 1) {
        final storeLocation = widget.pickup.deliveryRoute!.routeDetails!.last;

        if (storeLocation.latitude != null && storeLocation.longitude != null) {
          markers.add(
            Marker(
              point: LatLng(storeLocation.latitude!, storeLocation.longitude!),
              width: 45.w,
              height: 45.h,
              child: Container(
                decoration: BoxDecoration(
                  color: _currentStage >= 2 ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: Icon(Icons.store, color: Colors.white, size: 20.sp),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  List<LatLng> _generateRoute() {
    if (_routePoints.isNotEmpty) return _routePoints;

    // Fallback if routing fails
    if (_currentLocation == null) return [];

    final List<LatLng> routePoints = [
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
    ];

    if (widget.pickup.deliveryRoute?.routeDetails != null &&
        widget.pickup.deliveryRoute!.routeDetails!.isNotEmpty) {
      // Add customer location
      final customerLocation = widget.pickup.deliveryRoute!.routeDetails![0];

      if (customerLocation.latitude != null &&
          customerLocation.longitude != null) {
        routePoints.add(
          LatLng(customerLocation.latitude!, customerLocation.longitude!),
        );
      }

      // Add store location if in stage 2
      if (_currentStage >= 2 &&
          widget.pickup.deliveryRoute!.routeDetails!.length > 1) {
        final storeLocation = widget.pickup.deliveryRoute!.routeDetails!.last;

        if (storeLocation.latitude != null && storeLocation.longitude != null) {
          routePoints.add(
            LatLng(storeLocation.latitude!, storeLocation.longitude!),
          );
        }
      }
    }
    return routePoints;
  }

  String _getStageTitle() {
    if (widget.locationType == 'customer') {
      switch (_currentStage) {
        case 0:
          return 'Going to Customer Location';
        case 1:
          return 'Arrived at Customer Location';
        default:
          return 'Pickup Order';
      }
    } else {
      switch (_currentStage) {
        case 0:
          return 'Going to Seller Location';
        case 1:
          return 'Arrived at Seller Location';
        default:
          return 'Pickup Order';
      }
    }
  }

  String _getStageDescription() {
    if (widget.locationType == 'customer') {
      switch (_currentStage) {
        case 0:
          return 'Navigate to customer location to pick up the order';
        case 1:
          return 'Arrived at customer location. Click "Pick Up Order" to confirm';
        default:
          return '';
      }
    } else {
      switch (_currentStage) {
        case 0:
          return 'Navigate to seller location to return the order';
        case 1:
          return 'Arrived at seller location. Click "Confirm Return" to complete';
        default:
          return '';
      }
    }
  }

  void _showArrivalConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Arrival'),
            content: Text(
              widget.locationType == 'customer'
                  ? (_currentStage == 0
                      ? 'Have you reached the customer location?'
                      : 'Ready to pick up the order?')
                  : (_currentStage == 0
                      ? 'Have you reached the seller location?'
                      : 'Ready to return the order?'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    if (_currentStage == 0) {
                      _currentStage = 1;
                    } else if (_currentStage == 1) {
                      _currentStage = 2;
                    }
                  });

                  // Re-fetch route for next stage
                  _updateRoute();

                  ToastManager.show(
                    context: context,
                    message: 'Arrival confirmed!',
                    type: ToastType.success,
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return CustomScaffold(
          appBar: CustomAppBarWithoutNavbar(
            title: _getStageTitle(),
            showRefreshButton: false,
            showThemeToggle: false,
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _getCurrentLocationLatLng(),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _generateRoute(),
                        strokeWidth: 3.sp,
                        color: const Color(0xFF059669),
                      ),
                    ],
                  ),
                  MarkerLayer(markers: _buildMarkers()),
                ],
              ),
              // Map Controls (Right side)
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'recenter_pickup',
                        onPressed: _recenterMap,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: Icon(
                          Icons.my_location,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      FloatingActionButton(
                        heroTag: 'navigation_pickup',
                        onPressed: () async {
                          try {
                            final currentLocation = _getCurrentLocationLatLng();
                            final currentLat =
                                currentLocation.latitude.toString();
                            final currentLng =
                                currentLocation.longitude.toString();

                            String destinationAddress = 'Destination';

                            if (widget.pickup.deliveryRoute?.routeDetails !=
                                    null &&
                                widget
                                    .pickup
                                    .deliveryRoute!
                                    .routeDetails!
                                    .isNotEmpty) {
                              final targetLocation =
                                  _currentStage == 0
                                      ? widget
                                          .pickup
                                          .deliveryRoute!
                                          .routeDetails![0]
                                      : widget
                                          .pickup
                                          .deliveryRoute!
                                          .routeDetails!
                                          .last;

                              if (targetLocation.address != null &&
                                  targetLocation.address!.isNotEmpty) {
                                destinationAddress = targetLocation.address!;
                              }
                            }

                            final googleMapsUrl =
                                'https://www.google.com/maps/dir/?api=1'
                                '&origin=${Uri.encodeComponent('$currentLat,$currentLng')}'
                                '&destination=${Uri.encodeComponent(destinationAddress)}'
                                '&travelmode=driving';

                            final url = Uri.parse(googleMapsUrl);
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            ToastManager.show(
                              context: context,
                              message: 'Could not open navigation: $e',
                              type: ToastType.error,
                            );
                          }
                        },
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.navigation),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable Bottom Card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: true,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15.r,
                          offset: Offset(0, 5.h),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle/Header
                        GestureDetector(
                          onTap:
                              () => setState(() => _isExpanded = !_isExpanded),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping,
                                    color: AppColors.primaryColor,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  CustomText(
                                    text: _getStageTitle(),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),

                        if (_isExpanded) ...[
                          SizedBox(height: 12.h),
                          CustomText(
                            text: _getStageDescription(),
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 20.h),
                          // Action buttons
                          if (_currentStage == 0 || _currentStage == 1)
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                textSize: 15.sp,
                                text:
                                    _currentStage == 0
                                        ? (widget.locationType == 'customer'
                                            ? 'Arrived at Customer'
                                            : 'Arrived at Seller')
                                        : (widget.locationType == 'customer'
                                            ? 'Pick Up Order'
                                            : 'Confirm Return'),
                                onPressed: _showArrivalConfirmationDialog,
                                icon: Icon(
                                  _currentStage == 0
                                      ? Icons.location_on
                                      : (widget.locationType == 'customer'
                                          ? Icons.shopping_bag
                                          : Icons.check_circle),
                                  color: Colors.white,
                                ),
                                backgroundColor: AppColors.primaryColor,
                                textColor: Colors.white,
                                borderRadius: 12.r,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (_currentStage == 2)
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                textSize: 15.sp,
                                text: 'Arrived at Store',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text(
                                            'Return Order to Store',
                                          ),
                                          content: const Text(
                                            'Have you returned the order to the store?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(ctx),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                context.pop();
                                                ToastManager.show(
                                                  context: context,
                                                  message:
                                                      'Order returned to store. You can now update the status.',
                                                  type: ToastType.success,
                                                );
                                              },
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                borderRadius: 12.r,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
