import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:hyper_local/config/theme.dart';
import 'package:hyper_local/screens/my_orders/bloc/delivery_tracking/delivery_tracking_bloc.dart';
import 'package:hyper_local/config/global.dart';
import 'package:hyper_local/screens/my_orders/model/delivery_tracking_model.dart';
import 'package:hyper_local/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import 'package:hyper_local/screens/my_orders/widgets/tracking_map_style.dart';
import '../../../config/helper.dart';
import '../../../utils/widgets/custom_scaffold.dart';
import '../widgets/road_route.dart';

class DeliveryTrackingPage extends StatefulWidget {
  final String orderSlug;
  final bool isParcel;

  const DeliveryTrackingPage({
    super.key,
    required this.orderSlug,
    this.isParcel = false,
  });

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  GoogleMapController? mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  LatLng _initialPosition = const LatLng(20.0, 73.7); // Fallback to Nashik area
  LatLng? _currentLocation;
  LatLng? _deliveryPartnerLocation;
  LatLng? _previousLocation;
  double _riderRotation = 0.0;
  LatLng? _destinationLocation;

  Uint8List? _meIconBytes;
  Uint8List? _deliveryBoyIconBytes;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  DeliveryBoyTrackingModel? _currentTracking;

  @override
  void initState() {
    super.initState();

    _loadDeliveryBoyIcon();
    _ensureMeMarkerIcon();
    _setMarkersAndPolyline();

    context.read<DeliveryTrackingBloc>().add(
          FetchDeliveryTracking(
            orderSlug: widget.orderSlug,
            isParcel: widget.isParcel,
          ),
        );
  }

  Future<void> _loadDeliveryBoyIcon() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/images/delivery-boy.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final resized = await _resizeImage(bytes, 40, 40);
      if (mounted) {
        setState(() => _deliveryBoyIconBytes = resized);
        _setMarkersAndPolyline();
      }
    } catch (e) {
      debugPrint("Failed to load delivery boy icon: $e");
    }
  }

  Future<void> _ensureMeMarkerIcon() async {
    if (_meIconBytes != null) return;

    final profileUrl = Global.userData?.profileImage;
    final bytes = await buildPinLocationMarkerBytes(
      profileUrl,
      size: 35,
      pinColor: Colors.blue,
    );

    if (mounted) {
      setState(() {
        _meIconBytes = bytes;
        _setMarkersAndPolyline();
      });
    }
  }

  bool _isCalculatingRoute = false;

  void _setMarkersAndPolyline() async {
    if (_isCalculatingRoute) return;
    _isCalculatingRoute = true;

    try {
      final Set<Marker> newMarkers = {};
      final Set<Polyline> newPolylines = {};

      // Delivery Partner
      if (_deliveryPartnerLocation != null && _deliveryBoyIconBytes != null) {
        newMarkers.add(
          Marker(
            markerId: const MarkerId('partner'),
            position: _deliveryPartnerLocation!,
            icon: BitmapDescriptor.bytes(_deliveryBoyIconBytes!),
            rotation: _riderRotation,
            anchor: const Offset(0.5, 0.5),
            zIndex: 3,
          ),
        );
      }

      // Receiver/Destination marker only
      if (_currentLocation != null && _meIconBytes != null) {
        newMarkers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: _currentLocation!,
            icon: BitmapDescriptor.bytes(_meIconBytes!),
            infoWindow: const InfoWindow(title: "Receiver"),
          ),
        );
      }

      // Road route (Multi-segment for parcels)
      if (_deliveryPartnerLocation != null) {
        final stops = _currentTracking?.data?.route?.routeDetails ?? [];
        List<LatLng> fullRoutePoints = [];

        if (widget.isParcel && stops.length >= 2) {
          final receiverStop = stops.firstWhere(
            (s) => (s.storeName ?? '').toLowerCase().contains('receiver'),
            orElse: () => stops.last,
          );
          final receiverLoc =
              LatLng(receiverStop.latitude!, receiverStop.longitude!);

          fullRoutePoints =
              await getRoadRoute(_deliveryPartnerLocation!, receiverLoc);
        } else if (_currentLocation != null) {
          fullRoutePoints =
              await getRoadRoute(_deliveryPartnerLocation!, _currentLocation!);
        }

        print("[TRACKING] Route points found: ${fullRoutePoints.length}");

        if (fullRoutePoints.isNotEmpty) {
          newPolylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: fullRoutePoints,
              color: AppTheme.primaryColor,
              width: 5,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
          _polylines.clear();
          _polylines.addAll(newPolylines);
        });
      }
    } catch (e) {
      print("[TRACKING] Error in _setMarkersAndPolyline: $e");
    } finally {
      _isCalculatingRoute = false;
    }
  }

  Future<Uint8List> _resizeImage(Uint8List data, int width, int height) async {
    final codec = await ui.instantiateImageCodec(data,
        targetWidth: width, targetHeight: height);
    final frame = await codec.getNextFrame();
    final byteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> buildPinLocationMarkerBytes(
    String? imageUrl, {
    int size = 50,
    Color pinColor = Colors.blue,
    Color borderColor = Colors.white,
    double borderWidth = 4,
  }) async {
    ui.Image? networkImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final data =
            await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
            targetWidth: size - 20, targetHeight: size - 20);
        final frame = await codec.getNextFrame();
        networkImage = frame.image;
      } catch (e) {
        log("Failed to load profile image: $e");
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final double radius = size / 2;
    final double centerX = size / 2;
    final double centerY = radius;

    canvas.drawCircle(
      Offset(centerX, centerY + 6),
      radius,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final path = ui.Path()
      ..addOval(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius))
      ..moveTo(centerX - 20, centerY + radius - 10)
      ..lineTo(centerX, size * 1.4)
      ..lineTo(centerX + 20, centerY + radius - 10)
      ..close();

    canvas.drawPath(path, Paint()..color = pinColor);
    canvas.drawCircle(
        Offset(centerX, centerY), radius - 2, Paint()..color = borderColor);

    canvas.save();
    canvas.clipPath(ui.Path()
      ..addOval(ui.Rect.fromCircle(
          center: Offset(centerX, centerY), radius: radius - borderWidth)));

    if (networkImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromCircle(
            center: Offset(centerX, centerY), radius: radius - borderWidth),
        image: networkImage,
        fit: BoxFit.cover,
      );
    } else {
      final iconPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(centerX, centerY - 12), 16, iconPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(centerX - 18, centerY + 4, 36, 48),
          const Radius.circular(18),
        ),
        iconPaint,
      );
    }
    canvas.restore();

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), (size * 1.5).toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  Future<void> _onTrackingLoaded(DeliveryTrackingLoaded state) async {
    setState(() {
      _currentTracking = state.tracking;
    });

    final order = state.tracking.data?.order;
    final latStr = state.tracking.data?.deliveryBoy?.data?.latitude;
    final lngStr = state.tracking.data?.deliveryBoy?.data?.longitude;
    final lat = latStr != null ? double.tryParse(latStr.toString()) : null;
    final lng = lngStr != null ? double.tryParse(lngStr.toString()) : null;

    // Set Destination Locations and Current Target
    final stops = _currentTracking?.data?.route?.routeDetails ?? [];
    if (stops.isNotEmpty) {
      // For parcels, we might have multiple stops (Sender, Receiver)
      final isParcel = widget.isParcel;
      final status = (order?.status ?? "").toLowerCase();

      if (isParcel && stops.length >= 2) {
        // Always target the Receiver
        final receiverStop = stops.firstWhere(
          (s) => (s.storeName ?? '').toLowerCase().contains('receiver'),
          orElse: () => stops.last,
        );
        if (receiverStop.latitude != null && receiverStop.longitude != null) {
          _currentLocation =
              LatLng(receiverStop.latitude!, receiverStop.longitude!);
        }
      } else {
        // Standard order logic
        final customerStop = stops.firstWhere(
          (s) =>
              (s.storeName ?? '').toLowerCase().contains('customer') ||
              (s.storeName ?? '').toLowerCase().contains('custom'),
          orElse: () => stops.last,
        );
        if (customerStop.latitude != null && customerStop.longitude != null) {
          _currentLocation =
              LatLng(customerStop.latitude!, customerStop.longitude!);
        }
      }
    } else if (order?.shippingLatitude != null &&
        order?.shippingLongitude != null) {
      // Fallback
      final dLat = double.tryParse(order!.shippingLatitude!);
      final dLng = double.tryParse(order.shippingLongitude!);
      if (dLat != null && dLng != null) {
        _currentLocation = LatLng(dLat, dLng);
      }
    }

    if (lat != null && lng != null) {
      final newLoc = LatLng(lat, lng);
      if (_deliveryPartnerLocation != null) {
        _riderRotation = _calculateRotation(_deliveryPartnerLocation!, newLoc);
      }
      _deliveryPartnerLocation = newLoc;
      await _ensureMeMarkerIcon();
      _setMarkersAndPolyline();

      if (mounted) {
        mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_deliveryPartnerLocation!, 15.5));
      }
    } else {
      // If partner location is null, still show destination and wait for Firebase
      _setMarkersAndPolyline();
      if (_currentLocation != null && mounted) {
        mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_currentLocation!, 14.0));
      }
    }
  }

  // Firebase se real-time location update
  void _onFirebaseLocationUpdate(double lat, double lng) {
    final newLoc = LatLng(lat, lng);
    if (_deliveryPartnerLocation != null) {
      _riderRotation = _calculateRotation(_deliveryPartnerLocation!, newLoc);
    }
    _deliveryPartnerLocation = newLoc;
    _setMarkersAndPolyline();

    mapController?.animateCamera(
      CameraUpdate.newLatLng(_deliveryPartnerLocation!),
    );
  }

  double _calculateRotation(LatLng start, LatLng end) {
    final lat1 = start.latitude * math.pi / 180;
    final lon1 = start.longitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final lon2 = end.longitude * math.pi / 180;

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final radians = math.atan2(y, x);
    return (radians * 180 / math.pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showViewCart: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<DeliveryTrackingBloc, DeliveryTrackingState>(
        listener: (context, state) {
          if (state is DeliveryTrackingLoaded) {
            _onTrackingLoaded(state);
          }

          // Firebase real-time update
          if (state is DeliveryLocationUpdated) {
            _onFirebaseLocationUpdate(state.latitude, state.longitude);
          }

          if (state is OrderDelivered) {
            GoRouter.of(context).pop();
            GoRouter.of(context).push(
              AppRoutes.orderDelivered,
              extra: {
                'address': _currentTracking!.data!.order!.shippingAddress1,
                'addressType':
                    _currentTracking!.data!.order!.shippingAddressType,
                'orderSlug': _currentTracking!.data!.order!.slug,
              },
            );
          }
        },
        builder: (context, state) {
          final isFirstLoad =
              _currentTracking == null && state is DeliveryTrackingLoading;

          if (isFirstLoad) return _buildLoadingScreen();
          if (state is DeliveryTrackingFailed && _currentTracking == null) {
            return _buildErrorScreen(context);
          }

          return _buildMainUI(context, state);
        },
      ),
    );
  }

  Widget _buildLoadingScreen() => Stack(
        children: [
          _buildMap(),
          const Center(child: CustomCircularProgressIndicator()),
          _buildBackButton(),
        ],
      );

  Widget _buildErrorScreen(BuildContext context) => Stack(
        children: [
          _buildMap(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.failedToLoadTrackingData,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<DeliveryTrackingBloc>().add(
                        FetchDeliveryTracking(orderSlug: widget.orderSlug),
                      ),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
          _buildBackButton(),
        ],
      );

  Widget _buildMainUI(BuildContext context, DeliveryTrackingState state) {
    final order = _currentTracking?.data?.order;
    final routeDetails = _currentTracking?.data?.route?.routeDetails ?? [];
    final partnerName = order?.deliveryBoyName ??
        _currentTracking?.data?.deliveryBoy?.data?.deliveryBoy?.fullName ??
        'Delivery Partner';
    final partnerPhone = order?.deliveryBoyPhone?.toString();
    final deliveryPartnerProfile = order?.deliveryBoyProfile ?? '';

    final destTitle = order?.shippingAddressType ?? 'Destination';
    final destSubtitle = [
      order?.shippingAddress1,
      order?.shippingLandmark,
      order?.shippingCity
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');

    final orderIdText = order?.id?.toString() ?? '';
    final paymentText = (order?.paymentStatus?.toLowerCase() == 'paid')
        ? 'Paid ${order?.paymentMethod ?? ''}'.trim()
        : (order?.paymentMethod ?? '');
    final placedAtText = order?.createdAt ?? '';

    return Stack(
      children: [
        _buildMap(),
        _buildBackButton(),
        _buildRecenterButton(),

        PositionedDirectional(
          top: MediaQuery.of(context).padding.top + 10,
          end: 20,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode(context)
                  ? Theme.of(context).colorScheme.surface
                  : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8)
              ],
            ),
            child: state is DeliveryTrackingLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CustomCircularProgressIndicator(),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context.read<DeliveryTrackingBloc>().add(
                          FetchDeliveryTracking(
                            orderSlug: widget.orderSlug,
                            isParcel: widget.isParcel,
                          ),
                        ),
                  ),
          ),
        ),

        // Bottom Sheet (Swiggy Style Floating Card)
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.25,
          minChildSize: 0.25,
          maxChildSize: 0.6,
          builder: (_, scrollController) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Header with Gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order?.status == 'delivered'
                                      ? AppLocalizations.of(context)!.delivered
                                      : AppLocalizations.of(context)!.onTheWay,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order?.estimatedDeliveryTime != null
                                      ? '${AppLocalizations.of(context)!.arrivingIn} ${order?.estimatedDeliveryTime} ${AppLocalizations.of(context)!.mins}'
                                      : AppLocalizations.of(context)!
                                          .trackingLiveLocation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.timer_outlined,
                                  color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildDeliveryPartnerSection(
                    name: partnerName,
                    phone: partnerPhone,
                    deliveryBoyProfile: deliveryPartnerProfile,
                    vehicleType: _currentTracking
                        ?.data?.deliveryBoy?.data?.deliveryBoy?.vehicleType,
                  ),
                  _buildOrderDetailsSection(
                    orderId: orderIdText,
                    payment: paymentText,
                    deliveryType: order?.parcelType,
                    orderNumber: order?.slug,
                    chargePayBy: order?.chargePayBy,
                    placedAt: placedAtText,
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        // Apply Premium Swiggy Style
        final style =
            isDarkMode(context) ? premiumDarkMapStyle : premiumSilverMapStyle;
        mapController?.setMapStyle(style);
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: true,
      minMaxZoomPreference: const MinMaxZoomPreference(3, 18),
    );
  }

  Widget _buildBackButton() => PositionedDirectional(
        top: MediaQuery.of(context).padding.top + 10,
        start: 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );

  Widget _buildRecenterButton() {
    return PositionedDirectional(
      bottom: 150, // Positioned above the ultra-compact bottom sheet
      end: 20,
      child: InkWell(
        onTap: () {
          if (_deliveryPartnerLocation != null) {
            mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_deliveryPartnerLocation!, 16.5),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(
            Icons.my_location,
            color: AppTheme.primaryColor,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryPartnerSection({
    required String name,
    String? phone,
    String? deliveryBoyProfile,
    String? vehicleType,
  }) {
    final bool hasPhone =
        phone != null && phone.trim().isNotEmpty && phone != 'null';
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode(context) ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage:
                  (deliveryBoyProfile != null && deliveryBoyProfile.isNotEmpty)
                      ? NetworkImage(deliveryBoyProfile)
                      : null,
              backgroundColor: Colors.grey[200],
              child: (deliveryBoyProfile == null || deliveryBoyProfile.isEmpty)
                  ? Icon(Icons.person, size: 32, color: Colors.grey[600])
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.directions_bike,
                        color: AppTheme.primaryColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      vehicleType ??
                          AppLocalizations.of(context)!.deliveryPartner,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasPhone)
            InkWell(
              onTap: () => makePhoneCall(phoneNumber: phone, context: context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.call, color: Colors.green.shade700, size: 22),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsSection({
    required List<RouteDetail> stops,
    required String destTitle,
    required String destSubtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12.0),
          child: Text(
            AppLocalizations.of(context)!.deliveryDetails,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              for (final stop in stops) ...[
                _buildDeliveryLocation(
                  icon: Icons.store,
                  title: stop.storeName ?? 'Store',
                  subtitle: [stop.address, stop.landmark, stop.city]
                      .whereType<String>()
                      .where((s) => s.trim().isNotEmpty)
                      .join(', '),
                  iconColor: AppTheme.primaryColor,
                  isUser: stop.storeName == 'Customer Location',
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryLocation({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isUser,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailsSection({
    required String orderId,
    required String payment,
    required String? deliveryType,
    required String? orderNumber,
    required String? chargePayBy,
    required String placedAt,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)!.orderDetails,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              _buildOrderDetailRow("Parcel ID", orderId),
              _buildOrderDetailRow(
                  AppLocalizations.of(context)!.payment, payment),
              if (deliveryType != null)
                _buildOrderDetailRow("Delivery Type", deliveryType),
              if (orderNumber != null)
                _buildOrderDetailRow("Order Number", orderNumber),
              if (chargePayBy != null)
                _buildOrderDetailRow("Charge Pay By", chargePayBy),
              _buildOrderDetailRow(
                  AppLocalizations.of(context)!.orderPlaced, placedAt),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailRow(String label, String? value) {
    if (value == null ||
        value.isEmpty ||
        value.toLowerCase() == 'null' ||
        value == '0') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }
}

extension on LatLng {
  latlng.LatLng toLatLng2() => latlng.LatLng(latitude, longitude);
}
