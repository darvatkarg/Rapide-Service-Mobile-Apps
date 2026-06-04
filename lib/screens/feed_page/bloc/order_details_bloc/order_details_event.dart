import 'package:equatable/equatable.dart';

abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrderDetails extends OrderDetailsEvent {
  final int orderId;

  const FetchOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}


class FetchParcelDetails extends OrderDetailsEvent {
  final String pbId;

  const FetchParcelDetails(this.pbId);

  @override
  List<Object?> get props => [pbId];
}

class ChangeParcelStatus extends OrderDetailsEvent {
  final String pbId;
  final String status;

  const ChangeParcelStatus({
    required this.pbId,
    required this.status,
  });

  @override
  List<Object?> get props => [pbId, status];
}

class ChangeOrderStatus extends OrderDetailsEvent {
  final String id;
  final String status;

  const ChangeOrderStatus({
    required this.id,
    required this.status,
  });

  @override
  List<Object?> get props => [id, status];
}



class MarkItemReachedDestination extends OrderDetailsEvent {
  final int orderId;
  final int itemId;

  const MarkItemReachedDestination(this.orderId, this.itemId);

  @override
  List<Object?> get props => [orderId, itemId];
}
