import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hyper_local/screens/dashboard/model/notification_model.dart';
import 'package:hyper_local/screens/dashboard/repo/notification_list_repo.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationListRepo repo;

  NotificationBloc(this.repo) : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAsUnread>(_onMarkAsUnread);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<GetUnreadCount>(_onGetUnreadCount);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.page == 1) {
      emit(NotificationLoading());
    }

    try {
      final responseMap = await repo.getAllNotifications(
        page: event.page,
        perPage: event.perPage,
      );
      
      final response = NotificationListResponse.fromJson(responseMap);

      if (response.success && response.data != null) {
        if (event.page == 1) {
          emit(NotificationLoaded(
            notifications: response.data!.notifications,
            pagination: response.data!.pagination!,
          ));
          add(GetUnreadCount());
        } else {
          final currentState = state;
          if (currentState is NotificationLoaded) {
            emit(NotificationLoaded(
              notifications: [...currentState.notifications, ...response.data!.notifications],
              pagination: response.data!.pagination!,
            ));
          }
        }
      } else {
        emit(NotificationError(response.message));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final responseMap = await repo.markAsRead(event.id);
      if (responseMap['success'] == true) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == event.id) {
              return NotificationModel.fromJson({
                ...NotificationModel(
                  id: n.id,
                  userId: n.userId,
                  storeId: n.storeId,
                  orderId: n.orderId,
                  type: n.type,
                  sentTo: n.sentTo,
                  title: n.title,
                  message: n.message,
                  isRead: true,
                  data: n.data,
                  metadata: n.metadata,
                  createdAt: n.createdAt,
                  updatedAt: n.updatedAt,
                ).metadata != null ? {} : {}, // Simple way to trigger rebuild or manually map
                'id': n.id,
                'user_id': n.userId,
                'store_id': n.storeId,
                'order_id': n.orderId,
                'type': n.type,
                'sent_to': n.sentTo,
                'title': n.title,
                'message': n.message,
                'is_read': true,
                'data': n.data != null ? {
                  'title': n.data!.title,
                  'message': n.data!.message,
                  'type': n.data!.type,
                  'sent_to': n.data!.sentTo,
                  'user_id': n.data!.userId,
                  'order_id': n.data!.orderId,
                  'store_id': n.data!.storeId,
                  'metadata': n.data!.metadata,
                } : null,
                'metadata': n.metadata,
                'created_at': n.createdAt,
                'updated_at': n.updatedAt,
              });
            }
            return n;
          }).toList();
          emit(currentState.copyWith(notifications: updatedNotifications));
        }
        add(GetUnreadCount());
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onMarkAsUnread(
      MarkAsUnread event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      final responseMap = await repo.markAsUnRead(event.id);

      if (responseMap['success'] == true) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == event.id) {
              return NotificationModel.fromJson({
                'id': n.id,
                'user_id': n.userId,
                'store_id': n.storeId,
                'order_id': n.orderId,
                'type': n.type,
                'sent_to': n.sentTo,
                'title': n.title,
                'message': n.message,
                'is_read': false,           // ← changed to false
                'data': n.data != null ? {
                  'title': n.data!.title,
                  'message': n.data!.message,
                  'type': n.data!.type,
                  'sent_to': n.data!.sentTo,
                  'user_id': n.data!.userId,
                  'order_id': n.data!.orderId,
                  'store_id': n.data!.storeId,
                  'metadata': n.data!.metadata,
                } : null,
                'metadata': n.metadata,
                'created_at': n.createdAt,
                'updated_at': n.updatedAt,
              });
            }
            return n;
          }).toList();

          emit(currentState.copyWith(notifications: updatedNotifications));
        }
        add(GetUnreadCount());  // refresh unread badge/counter
      }
    } catch (e) {
      // Optionally emit error state or just silent fail (your current style)
      // emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final responseMap = await repo.markAllRead();
      if (responseMap['success'] == true) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedNotifications = currentState.notifications.map((n) {
             return NotificationModel.fromJson({
                'id': n.id,
                'user_id': n.userId,
                'store_id': n.storeId,
                'order_id': n.orderId,
                'type': n.type,
                'sent_to': n.sentTo,
                'title': n.title,
                'message': n.message,
                'is_read': true,
                'data': n.data != null ? {
                  'title': n.data!.title,
                  'message': n.data!.message,
                  'type': n.data!.type,
                  'sent_to': n.data!.sentTo,
                  'user_id': n.data!.userId,
                  'order_id': n.data!.orderId,
                  'store_id': n.data!.storeId,
                  'metadata': n.data!.metadata,
                } : null,
                'metadata': n.metadata,
                'created_at': n.createdAt,
                'updated_at': n.updatedAt,
              });
          }).toList();
          emit(currentState.copyWith(notifications: updatedNotifications));
        }
        add(GetUnreadCount());
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onGetUnreadCount(
    GetUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final responseMap = await repo.getUnreadCount();
      final response = UnreadCountResponse.fromJson(responseMap);
      if (response.success) {
        if (state is NotificationLoaded) {
          emit((state as NotificationLoaded).copyWith(unreadCount: response.unreadCount));
        }
      }
    } catch (e) {
      // Handle error
    }
  }
}
