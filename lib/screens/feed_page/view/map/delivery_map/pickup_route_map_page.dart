import 'dart:async';
import 'dart:math' show sin, cos, atan2, sqrt;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import '../../../../../config/colors.dart';
import '../../../../../config/constant.dart';
import '../../../../../config/theme_bloc.dart';
import '../../../model/available_orders.dart';
import '../../../bloc/order_details_bloc/order_details_bloc.dart';
import '../../../bloc/order_details_bloc/order_details_event.dart';
import '../../../bloc/order_details_bloc/order_details_state.dart';
import '../../../../../utils/widgets/custom_button.dart';
import '../../../../../utils/widgets/custom_text.dart';
import '../../../../../utils/widgets/custom_appbar_without_navbar.dart';
import 'package:go_router/go_router.dart';
import '../../../../../router/app_routes.dart';
import '../../../../../utils/widgets/toast_message.dart';
import '../store_pickup_route/services/location_service.dart';
import '../../../../../services/routing_service.dart';

class PickupRouteMapPage extends StatefulWidget {
  final Orders order;
  final OrderDetailsBloc? bloc; // Add bloc parameter

  const PickupRouteMapPage({
    super.key,
    required this.order,
    this.bloc, // Make it optional
  });

  @override
  State<PickupRouteMapPage> createState() => _PickupRouteMapPageState();
}

class _PickupRouteMapPageState extends State<PickupRouteMapPage> {
  late MapController _mapController;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  bool _isLoadingLocation = true;
  bool _isExpanded = true;

  // Manual confirmation variables
  bool _hasReachedDestination = false;
  bool _hasConfirmedArrival = false;
  final RoutingService _routingService = RoutingService();
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    if (widget.bloc != null) {
      final currentState = widget.bloc!.state;
      if (currentState is OrderDetailsSuccess) {
        final hasAnyReachedDestination =
            currentState.order.items?.any(
              (item) => item.reachedDestination == true,
            ) ??
            false;
        if (hasAnyReachedDestination) {
          _hasReachedDestination = true;
        }
      }
    }

    // Also check the order data directly if bloc is not available
    if (widget.order.items != null) {
      final hasAnyReachedDestination = widget.order.items!.any(
        (item) => item.reachedDestination == true,
      );
      if (hasAnyReachedDestination) {
        _hasReachedDestination = true;
      }
    }

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
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startLiveTracking() async {
    // Initial location fetch
    await _getCurrentLocation();

    // Start listening for updates
    _locationSubscription = LocationService.getLocationStream().listen((locationData) {
      if (!mounted) return;
      
      final oldLocation = _currentLocation;
      setState(() {
        _currentLocation = locationData;
        _isLoadingLocation = false;
      });

      // Update route if location changed significantly
      if (oldLocation == null || 
          (oldLocation.latitude! - locationData.latitude!).abs() > 0.0001 ||
          (oldLocation.longitude! - locationData.longitude!).abs() > 0.0001) {
        _updateRoute();
      }
    });
  }

  Future<void> _updateRoute() async {
    if (_currentLocation == null) return;

    final start = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    LatLng? end;

    if (widget.order.deliveryRoute?.routeDetails != null &&
        widget.order.deliveryRoute!.routeDetails!.isNotEmpty) {
      final lastIndex = widget.order.deliveryRoute!.routeDetails!.length - 1;
      final targetLocation = widget.order.deliveryRoute!.routeDetails![lastIndex];

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

  void _checkArrivalStatus() {
    // Check if arrival has already been confirmed based on order data
    if (widget.order.items != null) {
      final hasAnyReachedDestination = widget.order.items!.any(
        (item) => item.reachedDestination == true,
      );
      if (hasAnyReachedDestination && !_hasReachedDestination) {
        setState(() {
          _hasReachedDestination = true;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check arrival status whenever dependencies change
    _checkArrivalStatus();
  }

  void _setFallbackLocation() {
    setState(() {
      // Use destination address coordinates as fallback location
      final destination = LocationService.getDestinationLocation(
        widget.order.deliveryRoute?.routeDetails,
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

    // Add seller/shipping address location (last item in route_details)
    if (widget.order.deliveryRoute?.routeDetails != null) {
      final routeDetails = widget.order.deliveryRoute!.routeDetails!;

      // Use the last item as destination (seller/shipping address)
      if (routeDetails.isNotEmpty) {
        final lastIndex = routeDetails.length - 1;
        final sellerAddress = routeDetails[lastIndex];

        // Check if seller coordinates are different from current location
        final currentLat = _currentLocation!.latitude!;
        final currentLng = _currentLocation!.longitude!;
        final sellerLat = sellerAddress.latitude;
        final sellerLng = sellerAddress.longitude;

        if (sellerLat != null && sellerLng != null) {
          // Check if coordinates are actually different (with larger tolerance)
          if ((sellerLat - currentLat).abs() > 0.001 ||
              (sellerLng - currentLng).abs() > 0.001) {
            final sellerPoint = LatLng(sellerLat, sellerLng);
            allPoints.add(sellerPoint);
          } else {
            // No fallback to Bhuj
          }
        } else {
          // No fallback to Bhuj
        }
      }
    }

    if (allPoints.length >= 2) {
      final bounds = LatLngBounds.fromPoints(allPoints);

      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50)),
      );
    } else {}
  }

  List<LatLng> _generatePickupRoute() {
    if (_currentLocation == null) return [];

    final List<LatLng> routePoints = [
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
    ];

    // For pickup route, destination should be the seller/shipping address (last item in route_details)
    if (widget.order.deliveryRoute?.routeDetails != null) {
      final routeDetails = widget.order.deliveryRoute!.routeDetails!;

      // Use the last item as destination (seller/shipping address)
      if (routeDetails.isNotEmpty) {
        final lastIndex = routeDetails.length - 1;
        final sellerAddress = routeDetails[lastIndex];

        // Check if seller coordinates are different from current location
        final currentLat = _currentLocation!.latitude!;
        final currentLng = _currentLocation!.longitude!;
        final sellerLat = sellerAddress.latitude;
        final sellerLng = sellerAddress.longitude;

        if (sellerLat != null && sellerLng != null) {
          // Check if coordinates are actually different (with larger tolerance)
          if ((sellerLat - currentLat).abs() > 0.001 ||
              (sellerLng - currentLng).abs() > 0.001) {
            final sellerPoint = LatLng(sellerLat, sellerLng);
            routePoints.add(sellerPoint);
          } else {
            // No fallback to Bhuj
          }
        } else {
          // No fallback to Bhuj
        }
      }
    }

    final validPoints =
        routePoints
            .where((p) => !p.latitude.isNaN && !p.longitude.isNaN)
            .toList();

    return validPoints;
  }

  List<Polyline> _generateDashedRoute() {
    final List<LatLng> points = _routePoints.isNotEmpty ? _routePoints : _generatePickupRoute();
    
    if (points.isEmpty) return [];

    return [
      Polyline(
        points: points,
        strokeWidth: 4.sp,
        color: const Color(0xFF059669),
      ),
    ];
  }

  // Calculate distance from current location to stores (excluding shipping address)
  double _calculateDistanceToStores() {
    if (_currentLocation == null) {
      return 0.0;
    }

    double totalDistanceToStores = 0.0;

    if (widget.order.deliveryRoute?.routeDetails != null) {
      final routeDetails = widget.order.deliveryRoute!.routeDetails!;

      // Exclude the last index (shipping address) - only include stores
      for (int i = 0; i < routeDetails.length - 1; i++) {
        final store = routeDetails[i];

        if (store.latitude != null && store.longitude != null) {
          final storePoint = LatLng(store.latitude!, store.longitude!);
          final currentPoint = _getCurrentLocationLatLng();

          if (!currentPoint.latitude.isNaN &&
              !currentPoint.longitude.isNaN &&
              !storePoint.latitude.isNaN &&
              !storePoint.longitude.isNaN) {
            const double earthRadius = 6371; // kilometers
            final lat1 = currentPoint.latitude * pi / 180;
            final lat2 = storePoint.latitude * pi / 180;
            final deltaLat =
                (storePoint.latitude - currentPoint.latitude) * pi / 180;
            final deltaLng =
                (storePoint.longitude - currentPoint.longitude) * pi / 180;

            final a =
                sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
            if (a > 1.0) continue; // Prevent NaN from acos
            final c = 2 * atan2(sqrt(a), sqrt(1 - a));

            final distanceToStore = earthRadius * c;
            totalDistanceToStores += distanceToStore;
          }
        }
      }
    }

    return totalDistanceToStores;
  }

  LatLng _getCurrentLocationLatLng() {
    if (_currentLocation != null) {
      return LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    }

    // Use shipping address coordinates as fallback
    if (widget.order.deliveryRoute?.routeDetails != null &&
        widget.order.deliveryRoute!.routeDetails!.isNotEmpty) {
      final lastIndex = widget.order.deliveryRoute!.routeDetails!.length - 1;
      final shippingAddress =
          widget.order.deliveryRoute!.routeDetails![lastIndex];

      if (shippingAddress.latitude != null &&
          shippingAddress.longitude != null) {
        return LatLng(shippingAddress.latitude!, shippingAddress.longitude!);
      }
    }

    // Final fallback to destination address
    return LocationService.getDestinationLocation(
      widget.order.deliveryRoute?.routeDetails,
    );
  }

  void _showArrivalConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green),
              SizedBox(width: 8.w),
              CustomText(
                text: AppLocalizations.of(context)!.confirmArrival,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          content: CustomText(
            text: AppLocalizations.of(context)!.haveYouReachedAddress,
            fontSize: 14.sp,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: CustomText(
                text: AppLocalizations.of(context)!.cancel,
                fontSize: 14.sp,
              ),
            ),
            CustomButton(
              textSize: 15.sp,
              text: AppLocalizations.of(context)!.yesImHere,
              onPressed: () {
                context.pop();
                setState(() {
                  _hasConfirmedArrival = true;
                  _hasReachedDestination =
                      true; // Set this to true to show "Arrival Confirmed"
                });

                // Mark ALL items as reached destination using the bloc from widget
                if (widget.order.items != null &&
                    widget.order.items!.isNotEmpty &&
                    widget.bloc != null) {
                  for (final item in widget.order.items!) {
                    if (item.id != null) {
                      widget.bloc!.add(
                        MarkItemReachedDestination(widget.order.id!, item.id!),
                      );
                    }
                  }
                } else {
                  //
                }

                // Show success message
                ToastManager.show(
                  context: context,
                  message: 'Arrival confirmed! You can now view order details.',
                  type: ToastType.success,
                );

                // Automatically navigate to order details page after 3 seconds
                Future.delayed(const Duration(seconds: 3), () {
                  if (!context.mounted) return;
                  if (mounted) {
                    context.pushNamed(
                      'orderDetails',
                      extra: {
                        'orderId': widget.order.id,
                        'from':
                            false, // Using false instead of string as expected by the route
                      },
                    );
                  }
                });
              },
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
            ),
          ],
        );
      },
    );
  }

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];

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
            angle: (_currentLocation!.heading ?? 0) * (pi / 180),
            child: Image.asset(
              'assets/images/delivery-boy-car.png',
              width: 50.w,
              height: 50.h,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.w),
                ),
                child: Icon(Icons.motorcycle, color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ),
      );
    }

    // Add seller/shipping address marker (last item in route_details)
    if (widget.order.deliveryRoute?.routeDetails != null) {
      final routeDetails = widget.order.deliveryRoute!.routeDetails!;

      // Use the last item as destination (seller/shipping address)
      if (routeDetails.isNotEmpty) {
        final lastIndex = routeDetails.length - 1;
        final sellerAddress = routeDetails[lastIndex];

        // Check if seller coordinates are different from current location
        final currentLat = _currentLocation!.latitude!;
        final currentLng = _currentLocation!.longitude!;
        final sellerLat = sellerAddress.latitude;
        final sellerLng = sellerAddress.longitude;

        if (sellerLat != null && sellerLng != null) {
          // Check if coordinates are actually different (with larger tolerance)
          if ((sellerLat - currentLat).abs() > 0.001 ||
              (sellerLng - currentLng).abs() > 0.001) {
            final sellerPoint = LatLng(sellerLat, sellerLng);

            markers.add(
              Marker(
                point: sellerPoint,
                width: 45.w,
                height: 45.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
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
                    Icons.home,
                    color: Colors.white,
                    size: 20.sp,
                  ), // Changed to home icon for shipping address
                ),
              ),
            );
          } else {
            // No fallback to Bhuj
          }
        } else {
          // No fallback to Bhuj
        }
      }
    }

    if (widget.order.shippingLatitude != null &&
        widget.order.shippingLongitude != null) {
      final lat = double.tryParse(widget.order.shippingLatitude!) ?? double.nan;
      final lng =
          double.tryParse(widget.order.shippingLongitude!) ?? double.nan;
      if (lat.isNaN || lng.isNaN) {
      } else {
        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 45.w,
            height: 45.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
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
              child: Icon(Icons.location_on, color: Colors.white, size: 20.sp),
            ),
          ),
        );
      }
    }

    final routePoints = _generatePickupRoute();
    if (routePoints.length > 2) {
      final bikeIndex = (routePoints.length / 2).floor();
      if (bikeIndex < routePoints.length) {
        // final bikePoint = routePoints[bikeIndex];
        // final nextIndex = (bikeIndex + 1).clamp(0, routePoints.length - 1);
        // final nextPoint = routePoints[nextIndex];
        // final angle =
        //     atan2(
        //       nextPoint.longitude - bikePoint.longitude,
        //       nextPoint.latitude - bikePoint.latitude,
        //     ) *
        //     10 /
        //     pi;
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.order.items != null) {
    //   final reachedDestinationItems =
    //       widget.order.items!
    //           .where((item) => item.reachedDestination == true)
    //           .length;
    //
    //   // Check if View Details button should be shown
    //   final shouldShowViewDetails =
    //       _hasReachedDestination || _hasConfirmedArrival;
    // }

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkTheme = themeState.currentTheme == 'dark';

        if (widget.order.deliveryRoute?.routeDetails != null) {
          for (
            int i = 0;
            i < widget.order.deliveryRoute!.routeDetails!.length;
            i++
          ) {
            // final store = widget.order.deliveryRoute!.routeDetails![i];
          }
        }

        return CustomScaffold(
          appBar: CustomAppBarWithoutNavbar(
            title: AppLocalizations.of(context)!.deliveryRoute,

            showRefreshButton: false,
            showThemeToggle: false,
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter:
                      _currentLocation != null
                          ? _getCurrentLocationLatLng()
                          : const LatLng(23.2530, 69.6693),
                  initialZoom: 13.0,
                  onMapReady: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_currentLocation != null) _fitMapToAllPoints();
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: packageName,
                    maxZoom: 19,
                    minZoom: 0.0,
                  ),
                  if (_currentLocation != null) ...[
                    PolylineLayer(polylines: _generateDashedRoute()),
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ],
              ),
              if (_isLoadingLocation)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: AppLocalizations.of(context)!.loadingMap,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 20,
                left: 20,
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.straighten,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        CustomText(
                          text:
                              '${_calculateDistanceToStores().toStringAsFixed(1)} km',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Map Controls (Right side)
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'recenter',
                        onPressed: _recenterMap,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: Icon(
                          Icons.my_location,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      FloatingActionButton(
                        heroTag: 'navigation',
                        onPressed: () async {
                          try {
                            final currentLocation = _getCurrentLocationLatLng();
                            final currentLat =
                                currentLocation.latitude.toString();
                            final currentLng =
                                currentLocation.longitude.toString();

                            String destinationAddress = 'Destination';

                            if (widget.order.shippingAddress1 != null) {
                              destinationAddress =
                                  widget.order.shippingAddress1!;
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
                            if (!context.mounted) return;
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
                      color:
                          isDarkTheme ? AppColors.cardDarkColor : Colors.white,
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
                          onTap: () => setState(() => _isExpanded = !_isExpanded),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  CustomText(
                                    text:
                                        AppLocalizations.of(
                                          context,
                                        )!.deliveryRoute,
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
                          SizedBox(height: 16.h),
                          if (widget.order.shippingAddress1 != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  color: Colors.grey,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: CustomText(
                                    text: widget.order.shippingAddress1!,
                                    fontSize: 13.sp,
                                    color: Colors.grey[700],
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              textSize: 15.sp,
                              text:
                                  _hasReachedDestination
                                      ? AppLocalizations.of(
                                        context,
                                      )!.arrivalConfirmed
                                      : AppLocalizations.of(
                                        context,
                                      )!.confirmArrival,
                              onPressed:
                                  _hasReachedDestination
                                      ? null
                                      : _showArrivalConfirmationDialog,
                              icon: Icon(
                                _hasReachedDestination
                                    ? Icons.check_circle
                                    : Icons.location_on,
                                color:
                                    _hasReachedDestination
                                        ? Colors.green
                                        : Colors.white,
                              ),
                              backgroundColor:
                                  _hasReachedDestination
                                      ? Colors.grey.shade200
                                      : AppColors.primaryColor,
                              textColor:
                                  _hasReachedDestination
                                      ? Colors.green
                                      : Colors.white,
                              borderRadius: 12.r,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _hasReachedDestination
                                        ? Colors.green
                                        : Colors.white,
                              ),
                            ),
                          ),
                          if (_hasReachedDestination) ...[
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  context.push(
                                    AppRoutes.orderDetails,
                                    extra: {
                                      'orderId': widget.order.id!,
                                      'from': true,
                                      'sourceTab': 1,
                                    },
                                  );
                                },
                                child: CustomText(
                                  text:
                                      AppLocalizations.of(context)!.viewDetails,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
