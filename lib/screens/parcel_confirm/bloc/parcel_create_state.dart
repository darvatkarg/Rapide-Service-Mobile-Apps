import 'package:equatable/equatable.dart';

abstract class ParcelCreateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ParcelCreateInitial extends ParcelCreateState {}
class GetMyParcelLoading extends ParcelCreateState {}

class ParcelCreatDone extends ParcelCreateState {
  final String message;
    final bool isUpdating;
  final bool isAdding;
  final bool isRemoving;
  final bool isUpdated;
  final bool isAdded;
  final bool isRemoved;

  ParcelCreatDone({
    required this.message,
    required this.isUpdating,
    required this.isAdding,
    required this.isRemoving,
    required this.isUpdated,
    required this.isAdded,
    required this.isRemoved,
  });

  ParcelCreatDone copyWith({
    String? message,
    bool? isUpdating,
    bool? isAdding,
    bool? isRemoving,
    bool? isUpdated,
    bool? isAdded,
    bool? isRemoved,

  }) {
    return ParcelCreatDone(
      message: message ?? this.message,
      isUpdating: isUpdating ?? this.isUpdating,
      isAdding: isAdding ?? this.isAdding,
      isRemoving: isRemoving ?? this.isRemoving,
      isUpdated: isUpdated ?? this.isUpdated,
      isAdded: isAdded ?? this.isAdded,
      isRemoved: isRemoved ?? this.isRemoved,
    );
  }

  @override
  List<Object?> get props => [
        message,
        isUpdating,
        isAdding,
        isRemoving,
        isUpdated,
        isAdded,
        isRemoved,
        
      ];
}
