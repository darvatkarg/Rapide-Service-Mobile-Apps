import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/theme.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/parcel_confirm/widget/textfield.dart';

import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:hyper_local/config/global.dart';
import 'package:hyper_local/config/distance_calculator.dart';
import 'package:hyper_local/config/securestorage_helper.dart';
import 'package:hyper_local/services/location/user_location_hive.dart';
import 'package:hyper_local/model/user_location/user_location_model.dart';

class ParcelLocationScreen extends StatefulWidget {
  const ParcelLocationScreen({super.key});

  @override
  State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
}

class _ParcelLocationScreenState extends State<ParcelLocationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<FormState> _senderFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _receiverFormKey = GlobalKey<FormState>();

  // ── Sender fields ──
  final TextEditingController senderLocationController =
      TextEditingController();
  final TextEditingController senderStreetController = TextEditingController();
  final TextEditingController senderHouseController = TextEditingController();
  final TextEditingController senderFloorController = TextEditingController();
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderPhoneController = TextEditingController();
  double? senderLat;
  double? senderLng;
  String? senderPhoneError;

  // ── Receiver fields ──
  final TextEditingController receiverLocationController =
      TextEditingController();
  final TextEditingController receiverStreetController =
      TextEditingController();
  final TextEditingController receiverHouseController = TextEditingController();
  final TextEditingController receiverFloorController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  double? receiverLat;
  double? receiverLng;
  String? receiverPhoneError;

  int? selectedAddressId;
  double chargePerKm = 0;
  double estimatedFee = 0;
  double distanceKm = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Pre-fill sender info from user data
    if (Global.userData != null) {
      senderNameController.text = Global.userData?.name ?? '';
      String mobile = Global.userData?.mobile ?? '';
      if (mobile.startsWith('+229')) {
        mobile = mobile.replaceFirst('+229', '');
      } else if (mobile.startsWith('229')) {
        mobile = mobile.replaceFirst('229', '');
      }
      senderPhoneController.text = mobile;
    }

    _initDeliveryCharge();
    _initSenderLocation();
  }

  Future<void> _initDeliveryCharge() async {
    final charge = await SecureStorageHelper.getStandardDeliveryCharge();
    if (mounted) {
      setState(() {
        chargePerKm = double.tryParse(charge ?? "0") ?? 0;
      });
      _calculateEstimatedFee();
    }
  }

  void _initSenderLocation() {
    final UserLocation? location = HiveLocationHelper.getCurrentUserLocation();
    if (location != null && location.latitude != 0) {
      setState(() {
        senderLat = location.latitude;
        senderLng = location.longitude;
        senderLocationController.text = location.fullAddress;
      });
      _calculateEstimatedFee();
    }
  }

  void _calculateEstimatedFee() {
    if (senderLat != null &&
        senderLng != null &&
        receiverLat != null &&
        receiverLng != null &&
        chargePerKm > 0) {
      distanceKm = calculateDistance(
        senderLat!,
        senderLng!,
        receiverLat!,
        receiverLng!,
      );
      setState(() {
        estimatedFee = (distanceKm * chargePerKm).ceilToDouble();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    senderLocationController.dispose();
    senderStreetController.dispose();
    senderHouseController.dispose();
    senderFloorController.dispose();
    senderNameController.dispose();
    senderPhoneController.dispose();
    receiverLocationController.dispose();
    receiverStreetController.dispose();
    receiverHouseController.dispose();
    receiverFloorController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    super.dispose();
  }

  void _navigateToPickLocation({required bool isSender}) async {
    final result = await GoRouter.of(context).push(
      AppRoutes.locationPicker,
      extra: {
        'isFromHomePage': true,
        'isFromAddressPage': false,
        'isEdit': false,
      },
    );
    if (result != null && result is Map) {
      setState(() {
        if (isSender) {
          senderLocationController.text = result['address'] ?? '';
          senderStreetController.text = result['street'] ?? '';
          senderHouseController.text = result['house'] ?? '';
          if (result['location'] != null) {
            senderLat = result['location'].latitude;
            senderLng = result['location'].longitude;
          }
        } else {
          receiverLocationController.text = result['address'] ?? '';
          receiverStreetController.text = result['street'] ?? '';
          receiverHouseController.text = result['house'] ?? '';
          if (result['location'] != null) {
            receiverLat = result['location'].latitude;
            receiverLng = result['location'].longitude;
          }
        }
      });
      _calculateEstimatedFee();
    }
  }

  bool _validateAndProceed() {
    final senderValid = _senderFormKey.currentState?.validate() ?? false;
    final receiverValid = _receiverFormKey.currentState?.validate() ?? false;

    if (!senderValid) {
      _tabController.animateTo(0);
      return false;
    }

    if (!receiverValid) {
      _tabController.animateTo(1);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final Map<String, dynamic> extraMap = extra is Map<String, dynamic>
        ? extra
        : {'category': extra is String ? extra : ''};
    final String category = extraMap['category'] ?? '';
    final String pbType = extraMap['pb_type'] ?? '';
    final int? intercityId = extraMap['intercity_id'];
    final dynamic intercityCharge = extraMap['charge'];
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n?.parcelLocation ?? "Parcel Location"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              splashBorderRadius: BorderRadius.circular(12),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_upward_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(l10n?.sender?.toUpperCase() ?? 'SENDER'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_downward_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(l10n?.receiver?.toUpperCase() ?? 'RECEIVER'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, -4),
              color: Colors.black12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (estimatedFee > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${l10n?.estimatedFee ?? 'Estimated Delivery Fee'}:",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "FCFA ${estimatedFee.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final isSenderTab = _tabController.index == 0;
                  if (isSenderTab) {
                    if (_senderFormKey.currentState?.validate() ?? false) {
                      _tabController.animateTo(1);
                    }
                  } else {
                    if (_validateAndProceed()) {
                      GoRouter.of(context)
                          .push(AppRoutes.parcelRequest, extra: {
                        "address": receiverLocationController.text,
                        "street": receiverStreetController.text,
                        "house": receiverHouseController.text,
                        "floor": receiverFloorController.text,
                        "receiverName": receiverNameController.text,
                        "receiverPhone": receiverPhoneController.text,
                        "category": category,
                        "pb_type": pbType,
                        "intercity_id": intercityId,
                        "intercity_charge": intercityCharge,
                        "receiverLat": receiverLat,
                        "receiverLng": receiverLng,
                        // Sender data
                        "senderAddress": senderLocationController.text,
                        "senderStreet": senderStreetController.text,
                        "senderHouse": senderHouseController.text,
                        "senderFloor": senderFloorController.text,
                        "senderName": senderNameController.text,
                        "senderPhone": senderPhoneController.text,
                        "senderLat": senderLat,
                        "senderLng": senderLng,
                      });
                    }
                  }
                },
                child: Text(
                  l10n?.saveContinue ?? "Continue",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SenderTabView(
            formKey: _senderFormKey,
            locationController: senderLocationController,
            streetController: senderStreetController,
            houseController: senderHouseController,
            floorController: senderFloorController,
            nameController: senderNameController,
            phoneController: senderPhoneController,
            onPickLocation: () => _navigateToPickLocation(isSender: true),
            l10n: l10n,
          ),
          _ReceiverTabView(
            formKey: _receiverFormKey,
            locationController: receiverLocationController,
            streetController: receiverStreetController,
            houseController: receiverHouseController,
            floorController: receiverFloorController,
            nameController: receiverNameController,
            phoneController: receiverPhoneController,
            onPickLocation: () => _navigateToPickLocation(isSender: false),
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

class _SenderTabView extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController locationController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onPickLocation;
  final AppLocalizations? l10n;

  const _SenderTabView({
    required this.formKey,
    required this.locationController,
    required this.streetController,
    required this.houseController,
    required this.floorController,
    required this.nameController,
    required this.phoneController,
    required this.onPickLocation,
    this.l10n,
  });

  @override
  State<_SenderTabView> createState() => _SenderTabViewState();
}

class _SenderTabViewState extends State<_SenderTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 80,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.l10n?.pickupLocation ?? "Pickup Location",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                GestureDetector(
                  onTap: widget.onPickLocation,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppTheme.primaryColor),
                      const SizedBox(width: 5),
                      Text(
                        widget.l10n?.selectFromMap ?? "Select from map",
                        style: const TextStyle(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppTextField(
              isEditable: false,
              controller: widget.locationController,
              label: widget.l10n?.address ?? "Select pickup address",
              hint: widget.l10n?.selectPickupAddress ?? "Select pickup address",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.l10n?.pleaseSelectPickupAddress ??
                      'Please select pickup address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: widget.streetController,
              label: widget.l10n?.street ?? "Street",
              hint: widget.l10n?.enterStreetName ?? "Enter street name",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.l10n?.pleaseEnterStreetName ??
                      'Please enter street name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: widget.houseController,
                    label: widget.l10n?.house ?? "House",
                    hint: widget.l10n?.enterHouseNumber ?? "Enter house number",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.l10n?.pleaseEnterHouseNumber ??
                            'Please enter house number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    controller: widget.floorController,
                    label: widget.l10n?.floor ?? "Floor",
                    hint: widget.l10n?.enterFloorNumber ?? "Enter floor number",
                    validator: (value) => null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.l10n?.senderInformation ?? "Sender Information",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: widget.nameController,
              label: widget.l10n?.senderName ?? "Sender's name *",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.l10n?.pleaseEnterSenderName ??
                      'Please enter sender name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(9),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                filled: true,
                fillColor: Colors.white,
                labelText:
                    widget.l10n?.senderPhone ?? "Sender's phone number *",
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelStyle: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text("+229"),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 1.6,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.l10n?.pleaseEnterSenderPhone ??
                      'Please enter sender phone number';
                }
                if (value.length != 9) {
                  return widget.l10n?.pleaseEnterValidPhone ??
                      'Please enter valid 9 digit phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiverTabView extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController locationController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onPickLocation;
  final AppLocalizations? l10n;

  const _ReceiverTabView({
    required this.formKey,
    required this.locationController,
    required this.streetController,
    required this.houseController,
    required this.floorController,
    required this.nameController,
    required this.phoneController,
    required this.onPickLocation,
    this.l10n,
  });

  @override
  State<_ReceiverTabView> createState() => _ReceiverTabViewState();
}

class _ReceiverTabViewState extends State<_ReceiverTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 80,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.l10n?.receiverLocation ?? "Delivery Location",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                GestureDetector(
                  onTap: widget.onPickLocation,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppTheme.primaryColor),
                      const SizedBox(width: 5),
                      Text(
                        widget.l10n?.selectFromMap ?? "Select from map",
                        style: const TextStyle(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppTextField(
              isEditable: false,
              controller: widget.locationController,
              label: widget.l10n?.address ?? "Select delivery address",
              hint: widget.l10n?.selectReceiverAddress ??
                  "Select delivery address",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.l10n?.pleaseSelectReceiverAddress ??
                      'Please select delivery address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: widget.streetController,
              label: widget.l10n?.street ?? "Street",
              hint: widget.l10n?.enterStreetName ?? "Enter street name",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter street name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: widget.houseController,
                    label: widget.l10n?.house ?? "House",
                    hint: widget.l10n?.enterHouseNumber ?? "Enter house number",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.l10n?.pleaseEnterHouseNumber ??
                            'Please enter house number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    controller: widget.floorController,
                    label: widget.l10n?.floor ?? "Floor",
                    hint: widget.l10n?.enterFloorNumber ?? "Enter floor number",
                    validator: (value) => null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.l10n?.receiverInformation ?? "Receiver Information",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: widget.nameController,
              label: widget.l10n?.receiverName ?? "Receiver's name *",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.l10n?.pleaseEnterReceiverName ??
                      'Please enter receiver name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(9),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                filled: true,
                fillColor: Colors.white,
                labelText:
                    widget.l10n?.receiverPhone ?? "Receiver's phone number *",
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelStyle: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text("+229"),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 1.6,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.l10n?.pleaseEnterReceiverPhone ??
                      'Please enter receiver phone number';
                }
                // ← fix: value is already non-null here, but use ?.length ?? 0 for safety
                if ((value?.length ?? 0) != 9) {
                  return widget.l10n?.pleaseEnterValidPhone ??
                      'Please enter valid 9 digit phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
