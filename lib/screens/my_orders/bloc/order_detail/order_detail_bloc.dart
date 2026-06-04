import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_local/screens/my_orders/model/my_parcel_detail_model.dart';

import '../../model/order_detail_model.dart';
import '../../repo/order_repo.dart';
part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc() : super(OrderDetailInitial()) {
    on<FetchOrderDetail>(_onFetchUserCart);
    on<FetchParcelOrderDetail>(_onFetchParcelOrderDetail);
  }

  final OrderRepository repository = OrderRepository();

  Future<void> _onFetchUserCart(
      FetchOrderDetail event, Emitter<OrderDetailState> emit) async {
    emit(OrderDetailLoading());
    try {
      final orderDetailData = await repository.getOrderDetail(
        orderSlug: event.orderSlug,
      );
      if (orderDetailData.first.success == true) {
        emit(OrderDetailLoaded(
            cartData: orderDetailData,
            message: orderDetailData.first.message ?? ''));
      }
    } catch (e) {
      emit(OrderDetailFailed(error: e.toString()));
    }
  }

  FutureOr<void> _onFetchParcelOrderDetail(
    FetchParcelOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailLoading());

    try {
      final parcelOrderDetailData = await repository.getParcelOrderDetail(
        id: event.id,
      );
      print('Parcel detail from bloc: $parcelOrderDetailData');

      if (parcelOrderDetailData != null) {
        emit(
          GetMyParcelOrderDetail(
            parcelDetails: parcelOrderDetailData,
          ),
        );
      } else {
        emit(OrderDetailFailed(error: "Parcel detail not found"));
      }
    } catch (e) {
      emit(OrderDetailFailed(error: e.toString()));
    }
  }
}
