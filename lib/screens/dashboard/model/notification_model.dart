class NotificationListResponse {
  final bool success;
  final String message;
  final NotificationListData? data;

  NotificationListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? NotificationListData.fromJson(json['data']) : null,
    );
  }
}

class NotificationListData {
  final List<NotificationModel> notifications;
  final Pagination? pagination;

  NotificationListData({
    required this.notifications,
    this.pagination,
  });

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    return NotificationListData(
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e))
              .toList() ??
          [],
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }
}

class NotificationModel {
  final String id;
  final int userId;
  final int? storeId;
  final int? orderId;
  final String type;
  final String sentTo;
  final String title;
  final String message;
  final bool isRead;
  final NotificationContentData? data;
  final dynamic metadata;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.storeId,
    this.orderId,
    required this.type,
    required this.sentTo,
    required this.title,
    required this.message,
    required this.isRead,
    this.data,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? 0,
      storeId: json['store_id'],
      orderId: json['order_id'],
      type: json['type'] ?? '',
      sentTo: json['sent_to'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      data: json['data'] != null ? NotificationContentData.fromJson(json['data']) : null,
      metadata: json['metadata'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class NotificationContentData {
  final String title;
  final String message;
  final String type;
  final String sentTo;
  final int userId;
  final int? orderId;
  final int? storeId;
  final dynamic metadata;

  NotificationContentData({
    required this.title,
    required this.message,
    required this.type,
    required this.sentTo,
    required this.userId,
    this.orderId,
    this.storeId,
    this.metadata,
  });

  factory NotificationContentData.fromJson(Map<String, dynamic> json) {
    return NotificationContentData(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      sentTo: json['sent_to'] ?? '',
      userId: json['user_id'] ?? 0,
      orderId: json['order_id'],
      storeId: json['store_id'],
      metadata: json['metadata'],
    );
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }
}

class UnreadCountResponse {
  final bool success;
  final String message;
  final int unreadCount;

  UnreadCountResponse({
    required this.success,
    required this.message,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      unreadCount: json['data']?['unread_count'] ?? 0,
    );
  }
}
