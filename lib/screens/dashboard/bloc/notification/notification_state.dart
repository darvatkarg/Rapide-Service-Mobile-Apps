part of 'notification_bloc.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final Pagination pagination;
  final int unreadCount;

  NotificationLoaded({
    required this.notifications,
    required this.pagination,
    this.unreadCount = 0,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    Pagination? pagination,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
