import 'package:equatable/equatable.dart';
import 'package:hyper_local/screens/feed_page/model/available_parcels_model.dart';
import '../../model/available_orders.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}
class ParcelDetailsLoading extends OrderDetailsState {}

class OrderDetailsSuccess extends OrderDetailsState {
  final Orders order;

  const OrderDetailsSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class ParcelDetailsSuccess extends OrderDetailsState {
  final Parcel order;

  const ParcelDetailsSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class ParcelStatusUpdated extends OrderDetailsState {
  final String message;

  const ParcelStatusUpdated(this.message);
}

class OrderStatusUpdated extends OrderDetailsState {
  final String message;

  const OrderStatusUpdated(this.message);
}
class OrderDetailsError extends OrderDetailsState {
  final String errorMessage;

  const OrderDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
