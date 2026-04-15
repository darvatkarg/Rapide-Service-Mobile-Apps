import 'package:equatable/equatable.dart';
import '../model/delivery_zone_model.dart';

abstract class DeliveryZoneState extends Equatable {
  const DeliveryZoneState();

  @override
  List<Object?> get props => [];
}

class DeliveryZoneInitial extends DeliveryZoneState {}

class DeliveryZoneLoading extends DeliveryZoneState {}

class DeliveryZoneLoaded extends DeliveryZoneState {
  final List<DeliveryZoneModel> zones;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;
  final String? searchQuery;

  const DeliveryZoneLoaded({
    required this.zones,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [zones, currentPage, lastPage, total, hasMore, searchQuery];

  DeliveryZoneLoaded copyWith({
    List<DeliveryZoneModel>? zones,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMore,
    String? searchQuery,
  }) {
    return DeliveryZoneLoaded(
      zones: zones ?? this.zones,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DeliveryZoneLoadingMore extends DeliveryZoneState {
  final List<DeliveryZoneModel> zones;
  final int currentPage;
  final String? searchQuery;

  const DeliveryZoneLoadingMore({
    required this.zones,
    required this.currentPage,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [zones, currentPage, searchQuery];
}

class DeliveryZoneDetailsLoading extends DeliveryZoneState {}

class DeliveryZoneDetailsLoaded extends DeliveryZoneState {
  final DeliveryZoneModel zone;

  const DeliveryZoneDetailsLoaded({required this.zone});

  @override
  List<Object?> get props => [zone];
}

class DeliveryZoneError extends DeliveryZoneState {
  final String message;

  const DeliveryZoneError({required this.message});

  @override
  List<Object?> get props => [message];
}
