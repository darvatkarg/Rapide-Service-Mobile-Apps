import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hyper_local/config/distance_calculator.dart';
import 'package:hyper_local/config/global.dart';
import 'package:hyper_local/config/securestorage_helper.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/router/app_routes.dart';

import 'package:hyper_local/screens/parcel_confirm/bloc/parcel_create_bloc.dart'
    show ParcelCreateBloc;
import 'package:hyper_local/screens/parcel_confirm/bloc/parcel_create_event.dart';
import 'package:hyper_local/screens/parcel_confirm/bloc/parcel_create_state.dart';
import 'package:hyper_local/services/auth_guard.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_local/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:hyper_local/utils/widgets/custom_toast.dart';

class ParcelRequestScreen extends StatefulWidget {
  const ParcelRequestScreen({super.key});

  @override
  State<ParcelRequestScreen> createState() => _ParcelRequestScreenState();
}

class _ParcelRequestScreenState extends State<ParcelRequestScreen> {
  late Map<String, dynamic> data;
  String payer = "Sender";
  String paymentMethod = "Online";
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverMobileController =
      TextEditingController();

  final TextEditingController _receiverAddressController =
      TextEditingController();

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  String? category;
  double? receiverLat;
  double? receiverLng;
  int? selectedAddressId;
  Future<bool> checkUserLoggedIn() async {
    final isLoggedIn = await AuthGuard.ensureLoggedIn(context);
    return isLoggedIn;
  }

  double chargePerKm = 0;
  double totalDeliveryCharge = 0;
  double distanceKm = 0;
  bool isDataLoaded = false;
  @override
  void initState() {
    super.initState();
    loadDeliveryCharge();
    loadSelectedAddressId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isDataLoaded) {
      data = GoRouterState.of(context).extra as Map<String, dynamic>;

      _receiverAddressController.text = data["address"] ?? "";
      _streetController.text = data["street"] ?? "";
      _houseController.text = data["house"] ?? "";
      _floorController.text = data["floor"] ?? "";
      _receiverNameController.text = data["receiverName"] ?? "";
      _receiverMobileController.text = data["receiverPhone"] ?? "";
      category = data["category"] ?? "";
      receiverLat = data["receiverLat"];
      receiverLng = data["receiverLng"];
      print("receiver lat in didChangeDependencies: ${receiverLat}");
      print("receiver lng in didChangeDependencies: ${receiverLng}");

      isDataLoaded = true;
    }
  }

  Future<void> loadDeliveryCharge() async {
    String? storedCharge =
        await SecureStorageHelper.getStandardDeliveryCharge();

    chargePerKm = double.tryParse(storedCharge ?? "0") ?? 0;

    print("Charge per kmmmmmmmmmmm: $chargePerKm");

    print("Delivery charge loaded from storage: $chargePerKm");

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadSelectedAddressId() async {
    final id = await SecureStorageHelper.getSelectedAddressId();

    print("Fetched Address ID from SecureStorage: $id");

    if (mounted) {
      setState(() {
        selectedAddressId = id;
      });
    }
  }

  void calculateDeliveryCharge(dynamic storedLocation) {
    if (storedLocation != null &&
        receiverLat != null &&
        receiverLng != null &&
        chargePerKm > 0) {
      distanceKm = calculateDistance(
        storedLocation.latitude,
        storedLocation.longitude,
        receiverLat!,
        receiverLng!,
      );

      totalDeliveryCharge = (chargePerKm * distanceKm).ceilToDouble();

      print("Distance: ${distanceKm.toStringAsFixed(2)} km");
      print("Charge per km: $chargePerKm");
      print("Total Delivery Charge: $totalDeliveryCharge");

      setState(() {});
    }
  }

  Future<void> addParcelApi() async {
    print("Selected Address ID: $selectedAddressId");
    if (await checkUserLoggedIn()) {
      if (mounted) {
        context.read<ParcelCreateBloc>().add(
              AddParcelRequest(
                addressId: selectedAddressId ?? 0,
                pbType: category!,
                rcName: _receiverNameController.text,
                rcMobile: _receiverMobileController.text,
                rcAddress: _receiverAddressController.text,
                rcLat: receiverLat!,
                receiverLong: receiverLng!,
                rcStreet: _streetController.text,
                rcHouse: _houseController.text,
                rcFloor: _floorController.text,
                pbStatus: "pending",
                pbWhoPay: payer,
                pbPayMethod: paymentMethod,
                pbDeliveryCharge: totalDeliveryCharge.toInt(),
              ),
            );
      }
    } else {
      if (mounted) {
        GoRouter.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(l10n?.parcelRequest ?? "Parcel Request"),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          foregroundColor: Colors.black,
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.total ?? "Total",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      Text( 
                        "FCFA",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                      ),
                      SizedBox(width: 5,),
                      Text(
                        totalDeliveryCharge.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    addParcelApi();

                    // GoRouter.of(context).push(AppRoutes.parcelSuccess);
                  },
                  child: Text(
                    l10n?.confirmParcelRequest ?? "Confirm Parcel Request",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: BlocListener<ParcelCreateBloc, ParcelCreateState>(
          listener: (context, state) {
            if (state is ParcelCreatDone) {
              if (state.isAdding) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CustomCircularProgressIndicator(),
                  ),
                );
              }

              if (state.isAdded) {
                Navigator.pop(context);
                ToastManager.show(
                    context: context,
                    message: state.message,
                    type: ToastType.success);

                GoRouter.of(context).push(AppRoutes.parcelSuccess);
              }

              if (!state.isAdded &&
                  !state.isAdding &&
                  state.message.isNotEmpty) {
                Navigator.pop(context);

                ToastManager.show(
                  context: context,
                  message: state.message,
                  type: ToastType.error,
                );
              }
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                _infoCard(
                  title: l10n?.senderDetails ?? "Sender Details",
                  name: Global.userData?.name ?? "",
                  phone: Global.userData?.mobile ?? "",
                ),
                const SizedBox(height: 16),
                _infoCard(
                  title: l10n?.receiverDetails ?? "Receiver Details",
                  name: "${_receiverNameController.text}",
                  phone: "${_receiverMobileController.text}",
                ),
                const SizedBox(height: 16),
                _addressCard(),
                const SizedBox(height: 16),
                _radioCard(
                  title: l10n?.whoWillPay ?? "Who will pay?",
                  groupValue: payer,
                  options: {
                    "Sender": l10n?.sender ?? "Sender",
                    "Receiver": l10n?.receiver ?? "Receiver",
                  },
                  onChanged: (val) {
                    setState(() {
                      payer = val!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _radioCard(
                  title: l10n?.paymentMethod ?? "Payment Method",
                  groupValue: paymentMethod,
                  options: {
                    "Online": l10n?.online ?? "Online",
                    "Cash": l10n?.cash ?? "Cash",
                  },
                  onChanged: (val) {
                    setState(() {
                      paymentMethod = val!;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ));
  }

  Widget _infoCard({
    required String title,
    required String name,
    required String phone,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(phone),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _addressCard() {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: Hive.box<dynamic>('userLocationBox').listenable(),
      builder: (context, Box<dynamic> box, _) {
        final storedLocation = box.get('user_location');
        print("Stored Locationedee: $storedLocation.latitude");
        // final locationIdentifier = storedLocation == null
        //     ? null
        //     : '${storedLocation.latitude}_${storedLocation.longitude}_${storedLocation.fullAddress}_${storedLocation.area}_${storedLocation.city}_${storedLocation.pincode}';

        if (totalDeliveryCharge == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            calculateDeliveryCharge(storedLocation);
          });
        }

        return Card(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.addressInformation ?? "Address Information",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        storedLocation?.fullAddress.isNotEmpty == true
                            ? storedLocation!.fullAddress
                            : '',
                      ),
                    ),
                  ],
                ),
                // Text(storedLocation.latitude.toString()),
                // Text(storedLocation.longitude.toString()),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _receiverAddressController.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _radioCard({
    required String title,
    required String groupValue,
    required Map<String, String> options,
    required Function(String?) onChanged,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: options.entries.map((entry) {
                return Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: entry.key,
                        groupValue: groupValue,
                        activeColor: Colors.blue,
                        onChanged: onChanged,
                      ),
                      Text(entry.value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
