

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String standardDeliveryChargeKey = "standard_delivery_charge";
  static const String selectedAddressIdKey = "selected_address_id";
  static const String parcelNumberKey = "parcel_number";

  static Future<void> saveStandardDeliveryCharge(String charge) async {
    await _storage.write(
      key: standardDeliveryChargeKey,
      value: charge,
    );
  }

  static Future<String?> getStandardDeliveryCharge() async {
    return await _storage.read(key: standardDeliveryChargeKey);
  }

  static Future<void> saveSelectedAddressId(int id) async {
  await _storage.write(
    key: selectedAddressIdKey,
    value: id.toString(),
  );
}
static Future<int?> getSelectedAddressId() async {
  final value = await _storage.read(key: selectedAddressIdKey);
  return value != null ? int.tryParse(value) : null;
}



static Future<void> saveParcelNumber(String pbNumber) async {
  await _storage.write(
    key: parcelNumberKey,
    value: pbNumber,
  );
}

static Future<String?> getParcelNumber() async {
  return await _storage.read(key: parcelNumberKey);
}
}