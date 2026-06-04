import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_local/screens/my_orders/model/ongoing_parcel_list_model.dart';
import '../../model/my_order_model.dart';
import '../../repo/order_repo.dart';
import 'get_my_order_event.dart';
import 'get_my_order_state.dart';

class GetMyOrderBloc extends Bloc<GetMyOrderEvent, GetMyOrderState> {
  GetMyOrderBloc() : super(GetMyOrderInitial()) {
    on<FetchMyOrder>(_onFetchMyOrder);
    on<FetchMoreMyOrder>(_onFetchMoreMyOrder);
    on<RefreshMyOrders>(_onRefreshMyOrders);
    on<FetchMyOngoingOrders>(_onFetchOngoingOrders);
    on<FetchMyParcelsHistory>(_onFetchParcelsHistory);
  }

  int currentPage = 1;
  int perPage = 15;
  bool _hasReachedMax = false;
  bool isLoadingMore = false;
  final OrderRepository repository = OrderRepository();

  Future<void> _onFetchMyOrder(
    FetchMyOrder event,
    Emitter<GetMyOrderState> emit,
  ) async {
    emit(GetMyOrderLoading());
    await _fetchOrders(emit, isRefresh: false);
  }

  // NEW: Refresh without showing full loading
  Future<void> _onRefreshMyOrders(
    RefreshMyOrders event,
    Emitter<GetMyOrderState> emit,
  ) async {
    if (state is GetMyOrderLoaded) {
      await _fetchOrders(emit, isRefresh: true);
    } else {
      emit(GetMyOrderLoading());
      await _fetchOrders(emit, isRefresh: false);
    }
  }

  /// Core fetch logic (used by both initial & refresh)
  Future<void> _fetchOrders(
    Emitter<GetMyOrderState> emit, {
    required bool isRefresh,
  }) async {
    try {
      // Reset pagination only on refresh or initial load
      if (isRefresh || state is! GetMyOrderLoaded) {
        currentPage = 1;
        _hasReachedMax = false;
        isLoadingMore = false;
      }

      final response = await repository.fetchMyOrderList(
        page: currentPage,
        perPage: perPage,
      );

      final newOrders = List<MyOrderData>.from(
        (response['data']['data'] as List).map((e) => MyOrderData.fromJson(e)),
      );

      final currentPageNum =
          int.tryParse(response['data']['current_page'].toString()) ?? 1;
      final lastPageNum =
          int.tryParse(response['data']['last_page'].toString()) ?? 1;
      _hasReachedMax =
          currentPageNum >= lastPageNum || newOrders.length < perPage;

      if (response['success'] == true) {
        emit(GetMyOrderLoaded(
          message: response['message'] ?? 'Orders loaded successfully',
          myOrderData: newOrders,
          hasReachedMax: _hasReachedMax,
          // isRefreshing: false, // if you add this field
        ));
      } else {
        emit(GetMyOrderFailed(
            error: response['message'] ?? 'Failed to load orders'));
      }
    } catch (e) {
      emit(GetMyOrderFailed(error: e.toString()));
    }
  }

  /// Load more orders
  Future<void> _onFetchMoreMyOrder(
      FetchMoreMyOrder event, Emitter<GetMyOrderState> emit) async {
    // Prevent multiple simultaneous calls
    if (_hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is GetMyOrderLoaded) {
      // Set loading state
      isLoadingMore = true;

      try {
        // Increment page BEFORE API call
        currentPage += 1;
        final response = await repository.fetchMyOrderList(
          page: currentPage,
          perPage: perPage,
        );

        final newOrderData = List<MyOrderData>.from(
            response['data']['data'].map((data) => MyOrderData.fromJson(data)));

        // Update hasReachedMax
        final currentTotal =
            int.parse(response['data']['current_page'].toString());
        final lastPageNum = int.parse(response['data']['last_page'].toString());
        _hasReachedMax =
            currentTotal >= lastPageNum || newOrderData.length < perPage;

        // Remove duplicates when combining lists
        final updatedOrderData =
            List<MyOrderData>.from(currentState.myOrderData);

        // Add only unique orders
        for (final newOrder in newOrderData) {
          if (!updatedOrderData.any((existing) => existing.id == newOrder.id)) {
            updatedOrderData.add(newOrder);
          }
        }

        if (response['success'] == true) {
          emit(GetMyOrderLoaded(
            message: response['message'],
            myOrderData: updatedOrderData,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(GetMyOrderFailed(error: response['message']));
        }
      } catch (e) {
        // Reset page on error
        currentPage -= 1;
        emit(GetMyOrderFailed(error: e.toString()));
      } finally {
        isLoadingMore = false;
      }
    }
  }

  FutureOr<void> _onFetchOngoingOrders(
    FetchMyOngoingOrders event,
    Emitter<GetMyOrderState> emit,
  ) async {
    emit(GetMyOrderLoading());
    print("FetchMyOngoingOrders event received");

    try {
      final response = await repository.fetchMyParcelOngoingOrderList();
      print('Parcel Ongoing Orders from bloc: $response');

      if (response['success'] == true) {
        final List<ParcelBookingData> parcels = List<ParcelBookingData>.from(
          (response['data'] as List).map((e) => ParcelBookingData.fromJson(e)),
        );

        emit(
          GetMyOngoingOrdersLoaded(
            message: response['message'] ?? '',
            parcelBookingData: parcels,
            hasReachedMax: true,
          ),
        );
      } else {
        emit(
          GetMyOrderFailed(
            error: response['message'] ?? 'Failed to load parcels',
          ),
        );
      }
    } catch (e) {
      emit(
        GetMyOrderFailed(
          error: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onFetchParcelsHistory(
      FetchMyParcelsHistory event, Emitter<GetMyOrderState> emit) async {
    emit(GetMyOrderLoading());
    print("FetchMyParcelsHistory event received");

    try {
      final response = await repository.fetchMyParcelhistoryList();
      print('Parcel History Orders from bloc: $response');

      if (response['success'] == true) {
        final List<ParcelBookingData> parcels = List<ParcelBookingData>.from(
          (response['data'] as List).map((e) => ParcelBookingData.fromJson(e)),
        );

        emit(
          GetMyParcelsHistoryLoaded(
            message: response['message'] ?? '',
            parcelBookingData: parcels,
            hasReachedMax: true,
          ),
        );
      } else {
        emit(
          GetMyOrderFailed(
            error: response['message'] ?? 'Failed to load parcels',
          ),
        );
      }
    } catch (e) {
      emit(
        GetMyOrderFailed(
          error: e.toString(),
        ),
      );
    }
  }
}
