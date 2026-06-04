part of 'delivery_tracking_bloc.dart';

abstract class DeliveryTrackingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDeliveryTracking extends DeliveryTrackingEvent {
  final String orderSlug;
  final bool isParcel;

  FetchDeliveryTracking({
    required this.orderSlug,
    this.isParcel = false,
  });

  @override
  List<Object?> get props => [orderSlug, isParcel];
}

class FirebaseLocationUpdated extends DeliveryTrackingEvent {
  final double latitude;
  final double longitude;

  FirebaseLocationUpdated({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
