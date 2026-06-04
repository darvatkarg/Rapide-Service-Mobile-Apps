import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/delivery_zone_repo.dart';
import 'delivery_zone_event.dart';
import 'delivery_zone_state.dart';

class DeliveryZoneBloc extends Bloc<DeliveryZoneEvent, DeliveryZoneState> {
  final DeliveryZoneRepository _repository = DeliveryZoneRepository();

  DeliveryZoneBloc() : super(DeliveryZoneInitial()) {
    on<FetchDeliveryZonesEvent>(_onFetchDeliveryZones);
    on<SearchDeliveryZonesEvent>(_onSearchDeliveryZones);
    on<LoadMoreDeliveryZonesEvent>(_onLoadMoreDeliveryZones);
    on<SelectDeliveryZoneEvent>(_onSelectDeliveryZone);
    on<ClearSelectedZoneEvent>(_onClearSelectedZone);
  }

  Future<void> _onFetchDeliveryZones(
    FetchDeliveryZonesEvent event,
    Emitter<DeliveryZoneState> emit,
  ) async {
    emit(DeliveryZoneLoading());

    try {
      final response = await _repository.getDeliveryZones(
        page: event.page,
        search: event.search,
      );

      emit(DeliveryZoneLoaded(
        zones: response.data.data,
        currentPage: response.data.currentPage,
        lastPage: response.data.lastPage,
        total: response.data.total,
        hasMore: response.data.currentPage < response.data.lastPage,
        searchQuery: event.search,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error in bloc: $e');
      }
      emit(DeliveryZoneError(message: e.toString()));
    }
  }

  Future<void> _onSearchDeliveryZones(
    SearchDeliveryZonesEvent event,
    Emitter<DeliveryZoneState> emit,
  ) async {
    emit(DeliveryZoneLoading());

    try {
      final response = await _repository.getDeliveryZones(
        page: 1,
        search: event.query.isEmpty ? null : event.query,
      );

      emit(DeliveryZoneLoaded(
        zones: response.data.data,
        currentPage: response.data.currentPage,
        lastPage: response.data.lastPage,
        total: response.data.total,
        hasMore: response.data.currentPage < response.data.lastPage,
        searchQuery: event.query.isEmpty ? null : event.query,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Search error: $e');
      }
      emit(DeliveryZoneError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreDeliveryZones(
    LoadMoreDeliveryZonesEvent event,
    Emitter<DeliveryZoneState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DeliveryZoneLoaded) return;

    if (!currentState.hasMore) return;

    emit(DeliveryZoneLoadingMore(
      zones: currentState.zones,
      currentPage: currentState.currentPage,
      searchQuery: currentState.searchQuery,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _repository.getDeliveryZones(
        page: nextPage,
        search: currentState.searchQuery,
      );

      final updatedZones = [...currentState.zones, ...response.data.data];

      emit(DeliveryZoneLoaded(
        zones: updatedZones,
        currentPage: response.data.currentPage,
        lastPage: response.data.lastPage,
        total: response.data.total,
        hasMore: response.data.currentPage < response.data.lastPage,
        searchQuery: currentState.searchQuery,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Load more error: $e');
      }
      // Return to previous state on error
      emit(currentState);
    }
  }

  Future<void> _onSelectDeliveryZone(
    SelectDeliveryZoneEvent event,
    Emitter<DeliveryZoneState> emit,
  ) async {
    emit(DeliveryZoneDetailsLoading());

    try {
      final zone = await _repository.getDeliveryZoneById(event.zoneId);
      emit(DeliveryZoneDetailsLoaded(zone: zone));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Zone details error: $e');
      }
      emit(DeliveryZoneError(message: e.toString()));
    }
  }

  Future<void> _onClearSelectedZone(
    ClearSelectedZoneEvent event,
    Emitter<DeliveryZoneState> emit,
  ) async {
    emit(DeliveryZoneInitial());
  }
}
