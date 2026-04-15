import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_local/config/securestorage_helper.dart';
import 'package:hyper_local/screens/parcel_confirm/bloc/parcel_create_event.dart';
import 'package:hyper_local/screens/parcel_confirm/bloc/parcel_create_state.dart';
import 'package:hyper_local/screens/parcel_confirm/repo/parcel_create_repo.dart';

class ParcelCreateBloc extends Bloc<ParcelCreateEvent, ParcelCreateState> {
  ParcelCreateBloc() : super(ParcelCreateInitial()) {
    on<AddParcelRequest>(_onAddParcelRequest);
    // on<FetchMyParcelOrder>(_onFetchMyParcelOrder);
  }

  int currentPage = 1;
  int perPage = 15;
  bool _hasReachedMax = false;
  bool isLoadingMore = false;
  final ParcelCreateRepo repository = ParcelCreateRepo();
  Future<void> _onAddParcelRequest(
    AddParcelRequest event,
    Emitter<ParcelCreateState> emit,
  ) async {
    emit(ParcelCreatDone(
      message: "",
      isUpdating: false,
      isAdding: true,
      isRemoving: false,
      isUpdated: false,
      isAdded: false,
      isRemoved: false,
    ));

    try {
      final response = await ParcelCreateRepo().createPackageRequest(
        addressId: event.addressId,
        pbType: event.pbType,
        rcName: event.rcName,
        rcMobile: event.rcMobile,
        rcAddress: event.rcAddress,
        rcLat: event.rcLat,
        rc_long: event.receiverLong,
        rcStreet: event.rcStreet,
        rcHouse: event.rcHouse,
        rcFloor: event.rcFloor,
        pbStatus: event.pbStatus,
        pbWhoPay: event.pbWhoPay,
        pbPayMethod: event.pbPayMethod,
        pbDeliveryCharge: event.pbDeliveryCharge,
      );

      print("Parcel Create response: $response");
      final pbNumber = response['data']['pb_number'];
      print("Fetched Parcel Number: $pbNumber");
      await SecureStorageHelper.saveParcelNumber(pbNumber);
      print("Parcel Number stored in SecureStorage: $pbNumber");

      emit(ParcelCreatDone(
        message: response['message'] ?? 'Parcel created successfullyy',
        isUpdating: false,
        isAdding: false,
        isRemoving: false,
        isUpdated: false,
        isAdded: true,
        isRemoved: false,
      ));
    } catch (e) {
      emit(ParcelCreatDone(
        message: e.toString(),
        isUpdating: false,
        isAdding: false,
        isRemoving: false,
        isUpdated: false,
        isAdded: false,
        isRemoved: false,
      ));
    }
  }

  // FutureOr<void> _onFetchMyParcelOrder(
  //     FetchMyParcelOrder event, Emitter<ParcelCreateState> emit) async {
  //   emit(GetMyParcelLoading());

  //   await _fetchMyParcelOrders(emit, isRefresh: false);
  // }

/*
  Future<void> _fetchMyParcelOrders(
    Emitter<ParcelCreateState> emit, {
    required bool isRefresh,
  }) async {
    try {
      // if (isRefresh || state is! ParcelCreatDone) {
      //   currentPage = 1;
      //   _hasReachedMax = false;
      //   isLoadingMore = false;
      // }

      final response = await repository.fetchAddressList(
    
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

  */
}
