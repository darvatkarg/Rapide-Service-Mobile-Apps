import 'package:equatable/equatable.dart';
import 'package:hyper_local/screens/my_orders/model/my_parcel_detail_model.dart';
import 'package:hyper_local/screens/my_orders/model/ongoing_parcel_list_model.dart';

import '../../model/my_order_model.dart';

abstract class GetMyOrderState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetMyOrderInitial extends GetMyOrderState {}

class GetMyOrderLoading extends GetMyOrderState {}

class GetMyOrderLoaded extends GetMyOrderState {
  final List<MyOrderData> myOrderData;
  final String message;
  final bool hasReachedMax;

  GetMyOrderLoaded({
    required this.message,
    required this.myOrderData,
    required this.hasReachedMax,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [message, myOrderData, hasReachedMax];
}

//final List<ParcelBookingData> parcelBookingData;
class GetMyOngoingOrdersLoaded extends GetMyOrderState {
  final List<ParcelBookingData> parcelBookingData;
  final String message;
  final bool hasReachedMax;

  GetMyOngoingOrdersLoaded({
    required this.message,
    required this.parcelBookingData,
    required this.hasReachedMax,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [message, parcelBookingData, hasReachedMax];
}

class GetMyParcelsHistoryLoaded extends GetMyOrderState {
  final List<ParcelBookingData> parcelBookingData;
  final String message;
  final bool hasReachedMax;

  GetMyParcelsHistoryLoaded({
    required this.message,
    required this.parcelBookingData,
    required this.hasReachedMax,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [message, parcelBookingData, hasReachedMax];
}

class GetMyOrderFailed extends GetMyOrderState {
  final String error;

  GetMyOrderFailed({required this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}


