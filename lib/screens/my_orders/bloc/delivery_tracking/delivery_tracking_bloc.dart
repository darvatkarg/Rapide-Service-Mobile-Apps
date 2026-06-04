import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/delivery_tracking_model.dart';
import '../../repo/order_repo.dart';

part 'delivery_tracking_event.dart';
part 'delivery_tracking_state.dart';

class DeliveryTrackingBloc
    extends Bloc<DeliveryTrackingEvent, DeliveryTrackingState> {
  DeliveryTrackingBloc() : super(DeliveryTrackingInitial()) {
    on<FetchDeliveryTracking>(_onFetchDeliveryTracking);
    on<FirebaseLocationUpdated>(_onFirebaseLocationUpdated); // 🆕
  }

  final OrderRepository repository = OrderRepository();
  StreamSubscription? _firebaseSubscription; // 🆕
  int? _currentDriverId; // 🆕

  Future<void> _onFetchDeliveryTracking(
    FetchDeliveryTracking event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    emit(DeliveryTrackingLoading());
    try {
      final tracking = await repository.getDeliveryTracking(
        orderSlug: event.orderSlug,
        isParcel: event.isParcel,
      );

      if (tracking == null) {
        emit(DeliveryTrackingFailed(error: 'No data'));
        return;
      }

      if (tracking.success == false &&
          tracking.message!.toLowerCase().contains('delivered')) {
        emit(OrderDelivered());
        return;
      }

      if (tracking.success == true) {
        emit(DeliveryTrackingLoaded(
          tracking: tracking,
          message: tracking.message ?? '',
        ));

        final driverId = tracking.data?.order?.deliveryBoyId;
        if (driverId != null && driverId != _currentDriverId) {
          _currentDriverId = driverId;
          _startFirebaseStream(driverId);
        }
      } else {
        emit(DeliveryTrackingFailed(
          error: tracking.message ?? 'Failed to load',
        ));
      }
    } catch (e) {
      emit(DeliveryTrackingFailed(error: e.toString()));
    }
  }

  // 🆕 Firebase real-time stream
  void _startFirebaseStream(int driverId) {
    _firebaseSubscription?.cancel();

    final ref = FirebaseDatabase.instance.ref('drivers/$driverId');
    _firebaseSubscription = ref.onValue.listen(
      (event) {
        final data = event.snapshot.value as Map?;
        if (data == null) return;

        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();

        if (lat != null && lng != null) {
          add(FirebaseLocationUpdated(latitude: lat, longitude: lng));
        }
      },
      onError: (e) => log('Firebase stream error: $e'),
    );
  }

  void _onFirebaseLocationUpdated(
    FirebaseLocationUpdated event,
    Emitter<DeliveryTrackingState> emit,
  ) {
    emit(DeliveryLocationUpdated(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
  }

  @override
  Future<void> close() {
    _firebaseSubscription?.cancel();
    return super.close();
  }
}
