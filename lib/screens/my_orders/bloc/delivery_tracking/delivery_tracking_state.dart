part of 'delivery_tracking_bloc.dart';

abstract class DeliveryTrackingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeliveryTrackingInitial extends DeliveryTrackingState {}

class DeliveryTrackingLoading extends DeliveryTrackingState {}

class OrderDelivered extends DeliveryTrackingState {}

class DeliveryTrackingLoaded extends DeliveryTrackingState {
  final DeliveryBoyTrackingModel tracking;
  final String message;

  DeliveryTrackingLoaded({
    required this.tracking,
    required this.message,
  });

  @override
  List<Object?> get props => [tracking, message];
}

class DeliveryLocationUpdated extends DeliveryTrackingState {
  final double latitude;
  final double longitude;

  DeliveryLocationUpdated({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class DeliveryTrackingFailed extends DeliveryTrackingState {
  final String error;

  DeliveryTrackingFailed({required this.error});

  @override
  List<Object?> get props => [error];
}
