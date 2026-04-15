import 'package:equatable/equatable.dart';

abstract class ParcelCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddParcelRequest extends ParcelCreateEvent {
  final int addressId;
  final String pbType;

  final String rcName;
  final String rcMobile;

  final String rcAddress;
  final double rcLat;
  final double receiverLong;

  final String rcStreet;
  final String rcHouse;
  final String rcFloor;

  final String pbStatus;
  final String pbWhoPay;
  final String pbPayMethod;
  final int pbDeliveryCharge;

  AddParcelRequest({
    required this.addressId,
    required this.pbType,
    required this.rcName,
    required this.rcMobile,
    required this.rcAddress,
    required this.rcLat,
    required this.receiverLong,
    required this.rcStreet,
    required this.rcHouse,
    required this.rcFloor,
    required this.pbStatus,
    required this.pbWhoPay,
    required this.pbPayMethod,
    required this.pbDeliveryCharge,
  });

  @override
  List<Object?> get props => [
        addressId,
        pbType,
        rcName,
        rcMobile,
        rcAddress,
        rcLat,
        receiverLong,
        rcStreet,
        rcHouse,
        rcFloor,
        pbStatus,
        pbWhoPay,
        pbPayMethod,
        pbDeliveryCharge,
      ];
}

class FetchMyParcelOrder extends ParcelCreateEvent {}


