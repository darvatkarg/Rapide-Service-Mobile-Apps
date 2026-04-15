import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/parcel_confirm/widget/textfield.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

class ParcelLocationScreen extends StatefulWidget {
  const ParcelLocationScreen({super.key});

  @override
  State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
}

class _ParcelLocationScreenState extends State<ParcelLocationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? phoneError;
  final TextEditingController locationController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController receiverEmailController = TextEditingController();

  int? selectedAddressId;
  double? receiverLat;
  double? receiverLng;
//  void _loadSelectedAddress() {
//     final selectedAddress = HiveSelectedAddressHelper.getSelectedAddress();
//     setState(() {
//       selectedAddressId = selectedAddress?.id;
//     });
//   }
  void _navigateToAddAddress() async {
    final result = await GoRouter.of(context).push(
      AppRoutes.locationPicker,
      extra: {
        'isFromHomePage': true,
        'isFromAddressPage': false,
        'isEdit': false,
      },
    );
    // _loadSelectedAddress();
    if (result != null && result is Map) {
      setState(() {
        locationController.text = result['address'] ?? '';
        receiverLat = result['lat'];
        receiverLng = result['lng'];
        print(
            "Selected address########: ${locationController.text}"); // Debug print

        print("receiver lat########: ${receiverLat}");
        print("receiver lng########: ${receiverLng}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = GoRouterState.of(context).extra as String;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n?.parcelLocation ?? "Receiver Location"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
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
              bool isValid = _formKey.currentState!.validate();

              setState(() {
                if (receiverPhoneController.text.isEmpty) {
                  phoneError = "Please enter receiver phone number";
                  isValid = false;
                } else {
                  phoneError = null;
                }
              });

              if (isValid) {
                GoRouter.of(context).push(AppRoutes.parcelRequest, extra: {
                  "address": locationController.text,
                  "street": streetController.text,
                  "house": houseController.text,
                  "floor": floorController.text,
                  "receiverName": receiverNameController.text,
                  "receiverPhone": receiverPhoneController.text,
                  "category": category,
                  "receiverLat": receiverLat,
                  "receiverLng": receiverLng,
                });
              }
            },
            child: Text(
              l10n?.saveContinue ?? "Save & Continue",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Delivery Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.deliveryLocation ?? "Delivery Location",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    GestureDetector(
                      onTap: () => _navigateToAddAddress(),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue),
                          SizedBox(width: 5),
                          Text(
                            l10n?.selectFromMap ?? "Select From Map",
                            style: TextStyle(color: Colors.blue),
                          )
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                AppTextField(
                  isEditable: false,
                  controller: locationController,
                  label: l10n?.address ?? "Select delivery address ",
                  hint:
                      l10n?.enterDeliveryAddress ?? "Select delivery address ",
                  // suffixIcon: const Icon(Icons.close),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select delivery address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: streetController,
                  label: l10n?.street ?? "Street",
                  hint: l10n?.enterStreetName ?? "Enter street name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter street name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// House + Floor
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: houseController,
                        label: l10n?.house ?? "House",
                        hint: l10n?.enterHouseNumber ?? "Enter house number",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter house number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: floorController,
                        label: l10n?.floor ?? "Floor",
                        hint: l10n?.enterFloorNumber ?? "Enter floor number",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter floor number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Text(
                  l10n?.receiverInformation ?? "Receiver Information",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 15),

                /// Receiver Name
                AppTextField(
                  controller: receiverNameController,
                  label: l10n?.receiverName ?? "Receiver's name *",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter receiver name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: receiverPhoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(9),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: "Receiver's phone number",
                    prefix: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text("+229"),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      phoneError = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter receiver phone number";
                    }
                    if (value.length != 9) {
                      return "Please enter valid 9 digit phone number";
                    }
                    return null;
                  },
                ),

                // IntlPhoneField(
                //   controller: receiverPhoneController,
                //   initialCountryCode: 'BJ',
                //   showDropdownIcon: false,
                //   disableLengthCheck: true,
                //   flagsButtonMargin: EdgeInsets.zero,
                //   flagsButtonPadding: EdgeInsets.zero,
                //   enabled: true,
                //   inputFormatters: [
                //     LengthLimitingTextInputFormatter(9),
                //     FilteringTextInputFormatter.digitsOnly,
                //   ],
                //   onChanged: (phone) {
                //     setState(() {
                //       phoneError = null;
                //     });
                //   },
                //   decoration: InputDecoration(
                //     prefixText: "+229 ",
                //     labelText: "Receiver's phone number",
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),

                // if (phoneError != null)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 8.0, left: 12),
                //     child: Text(
                //       phoneError!,
                //       style: TextStyle(color: Colors.red[900], fontSize: 12),
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
