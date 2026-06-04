import 'package:equatable/equatable.dart';
import '../../model/available_orders.dart';

abstract class AvailableOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AvailableOrdersInitial extends AvailableOrdersState {}

class AvailableOrdersLoading extends AvailableOrdersState {}

class AvailableOrdersRefreshing extends AvailableOrdersState {
  final List<Orders> availableOrders;
  final bool hasReachedMax;
  final int totalOrders;

  AvailableOrdersRefreshing({
    required this.availableOrders,
    required this.hasReachedMax,
    required this.totalOrders,
  });

  @override
  List<Object> get props => [availableOrders, hasReachedMax, totalOrders];
}

class AvailableOrdersError extends AvailableOrdersState {
  final String errorMessage;

  AvailableOrdersError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class AvailableOrdersLoaded extends AvailableOrdersState {
  final List<Orders> availableOrders;
  final bool hasReachedMax;
  final int totalOrders;

  AvailableOrdersLoaded({
    required this.availableOrders,
    required this.hasReachedMax,
    required this.totalOrders,
  });

  @override
  List<Object> get props => [availableOrders, hasReachedMax, totalOrders];
}

class AvailableOrdersDeleteSuccess extends AvailableOrdersState {
  AvailableOrdersDeleteSuccess();

  @override
  List<Object> get props => [];
}
