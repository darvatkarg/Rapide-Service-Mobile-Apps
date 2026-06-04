import 'package:equatable/equatable.dart';

abstract class ParcelCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddParcelRequest extends ParcelCreateEvent {
  final int addressId;
  final String pbType;

  // Sender fields
  final String sdName;
  final String sdEmail;
  final String sdMobile;
  final String sdAddress;
  final double sdLat;
  final double sdLong;
  final String sdStreet;
  final String sdHouse;
  final String sdFloor;

  // Receiver fields
  final String rcName;
  final String rcMobile;
  final String rcAddress;
  final double rcLat;
  final double rcLong;
  final String rcStreet;
  final String rcHouse;
  final String rcFloor;

  final String deliveryType;
  final int? intercityId;
  final String pbStatus;
  final String pbWhoPay;
  final String pbPayMethod;
  final double pbDeliveryCharge;

  AddParcelRequest({
    required this.addressId,
    required this.pbType,
    required this.sdName,
    required this.sdEmail,
    required this.sdMobile,
    required this.sdAddress,
    required this.sdLat,
    required this.sdLong,
    required this.sdStreet,
    required this.sdHouse,
    required this.sdFloor,
    required this.rcName,
    required this.rcMobile,
    required this.rcAddress,
    required this.rcLat,
    required this.rcLong,
    required this.rcStreet,
    required this.rcHouse,
    required this.rcFloor,
    required this.deliveryType,
    this.intercityId,
    required this.pbStatus,
    required this.pbWhoPay,
    required this.pbPayMethod,
    required this.pbDeliveryCharge,
  });

  @override
  List<Object?> get props => [
        addressId,
        pbType,
        sdName,
        sdEmail,
        sdMobile,
        sdAddress,
        sdLat,
        sdLong,
        sdStreet,
        sdHouse,
        sdFloor,
        rcName,
        rcMobile,
        rcAddress,
        rcLat,
        rcLong,
        rcStreet,
        rcHouse,
        rcFloor,
        deliveryType,
        intercityId,
        pbStatus,
        pbWhoPay,
        pbPayMethod,
        pbDeliveryCharge,
      ];
}

class FetchMyParcelOrder extends ParcelCreateEvent {}


