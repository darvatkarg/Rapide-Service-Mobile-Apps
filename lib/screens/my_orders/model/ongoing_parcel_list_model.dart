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
  final String? deliveryType;
  final int? intercityId;
  final String? sdName;
  final String? sdAddress;
  final String? sdMobile;
  final String? sdEmail;
  final String? sdStreet;
  final String? sdHouse;
  final String? sdFloor;

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
    this.deliveryType,
    this.intercityId,
    this.sdName,
    this.sdAddress,
    this.sdMobile,
    this.sdEmail,
    this.sdStreet,
    this.sdHouse,
    this.sdFloor,
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
      deliveryType: parseString(json['delivery_type']),
      intercityId: parseInt(json['intercity_id']),
      sdName: parseString(json['sd_name']),
      sdAddress: parseString(json['sd_address']),
      sdMobile: parseString(json['sd_mobile']),
      sdEmail: parseString(json['sd_email']),
      sdStreet: parseString(json['sd_street']),
      sdHouse: parseString(json['sd_house']),
      sdFloor: parseString(json['sd_floor']),
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
        'delivery_type': deliveryType,
        'intercity_id': intercityId,
        'sd_name': sdName,
        'sd_address': sdAddress,
        'sd_mobile': sdMobile,
        'sd_email': sdEmail,
        'sd_street': sdStreet,
        'sd_house': sdHouse,
        'sd_floor': sdFloor,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
