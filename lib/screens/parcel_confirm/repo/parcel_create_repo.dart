import 'package:hyper_local/config/api_base_helper.dart';
import 'package:hyper_local/config/api_routes.dart';
import 'package:hyper_local/config/helper.dart';

class ParcelCreateRepo {
  Future<Map<String, dynamic>> createPackageRequest({
    required int addressId,
    required String pbType,
    required String sdName,
    required String sdEmail,
    required String sdMobile,
    required String sdAddress,
    required double sdLat,
    required double sdLong,
    required String sdStreet,
    required String sdHouse,
    required String sdFloor,
    required String rcName,
    required String rcMobile,
    required String rcAddress,
    required double rcLat,
    required double rcLong,
    required String rcStreet,
    required String rcHouse,
    required String rcFloor,
    required String deliveryType,
    int? intercityId,
    required String pbStatus,
    required String pbWhoPay,
    required String pbPayMethod,
    required double pbDeliveryCharge,
  }) async {
    final payload = {
      "address_id": addressId,
      "pb_type": pbType,
      "sd_name": sdName,
      "sd_email": sdEmail,
      "sd_mobile": sdMobile,
      "sd_address": sdAddress,
      "sd_lat": sdLat,
      "sd_long": sdLong,
      "sd_street": sdStreet,
      "sd_house": sdHouse,
      "sd_floor": sdFloor,
      "rc_name": rcName,
      "rc_mobile": rcMobile,
      "rc_address": rcAddress,
      "rc_lat": rcLat,
      "rc_long": rcLong,
      "rc_street": rcStreet,
      "rc_house": rcHouse,
      "rc_floor": rcFloor,
      "delivery_type": deliveryType,
      if (intercityId != null) "intercity_id": intercityId,
      "pb_status": pbStatus,
      "pb_whoPay": pbWhoPay,
      "pb_payMethod": pbPayMethod,
      "pb_deliveryCharge": pbDeliveryCharge
    };

    print("Create Parcel API URL: ${ApiRoutes.createParcelApi}");
    print("Create Parcel API Payload: $payload");

    try {
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.createParcelApi,
        payload,
      );

      print("Parcel Create API Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return response.data;
        } else {
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      print("Create Parcel API ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchAddressList() async {
    try {
      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.getOngoingParcelsApi,
        {},
        isUserApi: true,
      );
      print("Ongoing Parcels API Response: ${response.data}");
      if (response.statusCode == 200 || response.data['success'] == true) {
        return response.data;
      } else {
        return {};
      }
    } catch (e) {
      print("Ongoing Parcels API Error: $e");
      throw ApiException('Failed to fetch ongoing parcels');
    }
  }

  // Future<Map<String, dynamic>> removeAddress ({required int addressId}) async {
  //   try{
  //     final response = await AppHelpers.apiBaseHelper.deleteAPICall(
  //         '${ApiRoutes.removeAddressesApi}${addressId.toString()}',
  //         {}
  //     );
  //     if(response.statusCode == 200) {
  //       return response.data;
  //     } else {
  //       return {};
  //     }
  //   }catch(e){
  //     throw ApiException('Failed to remove item from cart');
  //   }
  // }

  // Future<Map<String, dynamic>> updateAddress ({
  //   required int addressId,
  //   required String addressLine1,
  //   required String addressLine2,
  //   required String city,
  //   required String landmark,
  //   required String state,
  //   required String zipcode,
  //   required String mobile,
  //   required String addressType,
  //   required String country,
  //   required String countryCode,
  //   required String latitude,
  //   required String longitude,
  // }) async {
  //   try{
  //     final response = await AppHelpers.apiBaseHelper.putAPICall(
  //         '${ApiRoutes.updateAddressesApi}${addressId.toString()}',
  //         AppHelpers.isDemo ? AppHelpers.defaultFullAddress
  //             : {
  //           'address_line1': addressLine1,
  //           'address_line2': addressLine2,
  //           'city': city,
  //           'landmark': landmark,
  //           'state': state,
  //           'zipcode': zipcode,
  //           'mobile': mobile,
  //           'address_type': addressType.toLowerCase(),
  //           'country': country,
  //           'country_code': countryCode,
  //           'latitude': latitude,
  //           'longitude': longitude
  //         }
  //     );
  //     if(response.statusCode == 200) {
  //       return response.data;
  //     } else {
  //       return {};
  //     }
  //   }catch(e){
  //     throw ApiException('Failed to remove item from cart');
  //   }
  // }
}
