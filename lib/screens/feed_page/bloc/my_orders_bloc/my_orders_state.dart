import 'package:equatable/equatable.dart';
import 'package:hyper_local/screens/feed_page/model/available_parcels.dart';
import '../../model/available_orders.dart';

abstract class MyOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MyOrdersInitial extends MyOrdersState {}

class MyOrdersLoading extends MyOrdersState {}

class MyParcelsLoading extends MyOrdersState {}

class MyHistoryParcelsLoading extends MyOrdersState {}

class MyOrdersRefreshing extends MyOrdersState {
  final List<Orders> myOrders;
  final bool hasReachedMax;
  final int totalOrders;
  final String selectedFilter;

  MyOrdersRefreshing({
    required this.myOrders,
    required this.hasReachedMax,
    required this.totalOrders,
    required this.selectedFilter,
  });

  @override
  List<Object> get props => [
    myOrders,
    hasReachedMax,
    totalOrders,
    selectedFilter,
  ];
}

class MyOrdersError extends MyOrdersState {
  final String errorMessage;

  MyOrdersError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class MyOrdersLoaded extends MyOrdersState {
  final List<Orders> myOrders;
  final bool hasReachedMax;
  final int totalOrders;
  final String selectedFilter;

  MyOrdersLoaded({
    required this.myOrders,
    required this.hasReachedMax,
    required this.totalOrders,
    required this.selectedFilter,
  });

  @override
  List<Object> get props => [
    myOrders,
    hasReachedMax,
    totalOrders,
    selectedFilter,
  ];
}

class MyOngoingParcelsLoaded extends MyOrdersState {
  final List<AvailableParcels> availableParcels;
  // final bool hasReachedMax;
  // final int totalOrders;
  // final String selectedFilter;

  MyOngoingParcelsLoaded({
    required this.availableParcels,
    // required this.hasReachedMax,
    // required this.totalOrders,
    // required this.selectedFilter,
  });

  @override
  List<Object> get props => [availableParcels];
}

class MyHistoryParcelsLoaded extends MyOrdersState {
  final List<AvailableParcels> historyParcels;


  MyHistoryParcelsLoaded({
    required this.historyParcels,

  });

  @override
  List<Object> get props => [historyParcels];
}
