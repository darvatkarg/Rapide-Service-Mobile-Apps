import 'package:hyper_local/config/helper.dart';

class ParcelBookingData {
  final int? pbId;
  final int? userId;
  final int? addressId;

  final String? pbType;
  final String? pbNumber;

  final String? rcName;
  final String? rcAddress;
  final String? rcLat;
  final String? rcLong;
  final String? rcMobile;

  final String? rcStreet;
  final String? rcHouse;
  final String? rcFloor;

  final String? pbWhoPay;
  final String? pbPayMethod;
  final String? pbDeliveryCharge;
  final String? pbStatus;

  final String? createdAt;
  final String? updatedAt;

  ParcelBookingData({
    this.pbId,
    this.userId,
    this.addressId,
    this.pbType,
    this.pbNumber,
    this.rcName,
    this.rcAddress,
    this.rcLat,
    this.rcLong,
    this.rcMobile,
    this.rcStreet,
    this.rcHouse,
    this.rcFloor,
    this.pbWhoPay,
    this.pbPayMethod,
    this.pbDeliveryCharge,
    this.pbStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory ParcelBookingData.fromJson(Map<String, dynamic> json) {
    return ParcelBookingData(
      pbId: parseInt(json['pb_id']),
      userId: parseInt(json['user_id']),
      addressId: parseInt(json['address_id']),
      pbType: parseString(json['pb_type']),
      pbNumber: parseString(json['pb_number']),
      rcName: parseString(json['rc_name']),
      rcAddress: parseString(json['rc_address']),
      rcLat: parseString(json['rc_lat']),
      rcLong: parseString(json['rc_long']),
      rcMobile: parseString(json['rc_mobile']),
      rcStreet: parseString(json['rc_street']),
      rcHouse: parseString(json['rc_house']),
      rcFloor: parseString(json['rc_floor']),
      pbWhoPay: parseString(json['pb_whoPay']),
      pbPayMethod: parseString(json['pb_payMethod']),
      pbDeliveryCharge: parseString(json['pb_deliveryCharge']),
      pbStatus: parseString(json['pb_status']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'pb_id': pbId,
        'user_id': userId,
        'address_id': addressId,
        'pb_type': pbType,
        'pb_number': pbNumber,
        'rc_name': rcName,
        'rc_address': rcAddress,
        'rc_lat': rcLat,
        'rc_long': rcLong,
        'rc_mobile': rcMobile,
        'rc_street': rcStreet,
        'rc_house': rcHouse,
        'rc_floor': rcFloor,
        'pb_whoPay': pbWhoPay,
        'pb_payMethod': pbPayMethod,
        'pb_deliveryCharge': pbDeliveryCharge,
        'pb_status': pbStatus,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}