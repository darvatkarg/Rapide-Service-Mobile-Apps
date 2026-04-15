import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../config/api_base_helper.dart';

import '../../model/available_orders.dart';
import '../../repo/available_orders.dart';

import 'available_orders_event.dart';
import 'available_orders_state.dart';

class AvailableOrdersBloc
    extends Bloc<AvailableOrdersEvent, AvailableOrdersState> {
  int _offset = 0;
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoading = false;

  AvailableOrdersBloc() : super(AvailableOrdersInitial()) {
    on<AllAvailableOrdersList>(_onAllAvailableOrders);
    on<SearchAvailableOrders>(_onSearchAvailableOrders);
    on<LoadMoreAvailableOrders>(_onLoadMoreAvailableOrders);
  }

  Future<void> _onAllAvailableOrders(
    AllAvailableOrdersList event,
    Emitter<AvailableOrdersState> emit,
  ) async {
    try {
      // Only load if we don't have data or if explicitly requested
      if (state is AvailableOrdersLoaded) {
        // If we already have data, don't reload unless it's a manual refresh
        if (!event.forceRefresh) {
          return; // Keep existing data
        }
        final currentState = state as AvailableOrdersLoaded;
        emit(
          AvailableOrdersRefreshing(
            availableOrders: currentState.availableOrders,
            hasReachedMax: currentState.hasReachedMax,
            totalOrders: currentState.totalOrders,
          ),
        );
      } else {
        emit(AvailableOrdersLoading());
      }

      _offset = 0;
      _hasReachedMax = false;

      final response = await AvailableOrdersRepo().availableOrdersList(
        limit: _limit,
        offset: _offset,
        search: '',
      );

      final List<Orders> orders =
          (response['data']['orders'] as List<dynamic>?)
              ?.map((item) => Orders.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final int currentPage = response['data']['current_page'] as int;
      final int lastPage = response['data']['last_page'] as int;

      _offset += _limit;
      _hasReachedMax = currentPage >= lastPage;

      if (response['success'] == true) {
        emit(
          AvailableOrdersLoaded(
            availableOrders: orders,
            hasReachedMax: _hasReachedMax,
            totalOrders: response['data']['total'] as int,
          ),
        );
      } else {
        emit(AvailableOrdersError(response['message']));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {}
      emit(AvailableOrdersError("Error: $e"));
    } catch (e) {
      if (kDebugMode) {}
      emit(AvailableOrdersError("Unexpected error: $e"));
    }
  }

  Future<void> _onSearchAvailableOrders(
    SearchAvailableOrders event,
    Emitter<AvailableOrdersState> emit,
  ) async {
    try {
      emit(AvailableOrdersLoading());
      _offset = 0;
      _hasReachedMax = false;

      final response = await AvailableOrdersRepo().availableOrdersList(
        limit: _limit,
        offset: _offset,
        search: event.searchQuery,
      );

      final List<Orders> orders =
          (response['data']['orders'] as List<dynamic>?)
              ?.map((item) => Orders.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final int currentPage = response['data']['current_page'] as int;
      final int lastPage = response['data']['last_page'] as int;

      _hasReachedMax = currentPage >= lastPage;

      if (response['success'] == true) {
        emit(
          AvailableOrdersLoaded(
            availableOrders: orders,
            hasReachedMax: _hasReachedMax,
            totalOrders: response['data']['total'] as int,
          ),
        );
      } else {
        emit(AvailableOrdersError(response['message']));
      }
    } on ApiException catch (e) {
      emit(AvailableOrdersError("Error: $e"));
    } catch (e) {
      if (kDebugMode) {}
      emit(AvailableOrdersError("Unexpected error: $e"));
    }
  }

  Future<void> _onLoadMoreAvailableOrders(
    LoadMoreAvailableOrders event,
    Emitter<AvailableOrdersState> emit,
  ) async {
    if (state is AvailableOrdersLoaded && !_hasReachedMax && !_isLoading) {
      _isLoading = true;
      try {
        final currentState = state as AvailableOrdersLoaded;
        List<Orders> currentOrders = List<Orders>.from(
          currentState.availableOrders,
        );

        final response = await AvailableOrdersRepo().availableOrdersList(
          limit: _limit,
          offset: _offset,
          search: '',
        );

        final List<Orders> newOrders =
            (response['data']['orders'] as List<dynamic>?)
                ?.map((item) => Orders.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final int currentPage = response['data']['current_page'] as int;
        final int lastPage = response['data']['last_page'] as int;

        _offset += _limit;
        _hasReachedMax = currentPage >= lastPage;

        currentOrders.addAll(newOrders);

        if (response['success'] == true) {
          emit(
            AvailableOrdersLoaded(
              availableOrders: currentOrders,
              hasReachedMax: _hasReachedMax,
              totalOrders: response['data']['total'] as int,
            ),
          );
        } else {
          emit(AvailableOrdersError(response['message']));
        }
      } on ApiException catch (e) {
        emit(AvailableOrdersError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {}
        emit(AvailableOrdersError("Unexpected error: $e"));
      } finally {
        _isLoading = false;
      }
    }
  }
}
