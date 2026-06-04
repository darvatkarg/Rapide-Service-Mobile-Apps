class TopUpHistoryResponse {
  final bool success;
  final String message;
  final TopUpHistoryData data;

  TopUpHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TopUpHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TopUpHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TopUpHistoryData.fromJson(json['data'] ?? {}),
    );
  }
}

class TopUpHistoryData {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<TopUpHistoryModel> transactions;

  TopUpHistoryData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.transactions,
  });

  factory TopUpHistoryData.fromJson(Map<String, dynamic> json) {
    return TopUpHistoryData(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      transactions:
          (json['data'] as List<dynamic>? ?? [])
              .map((e) => TopUpHistoryModel.fromJson(e))
              .toList(),
    );
  }
}

class TopUpHistoryModel {
  final int? id;
  final int? walletId;
  final int? userId;
  final dynamic orderId;
  final dynamic storeId;
  final String? transactionType;
  final String? paymentMethod;
  final String? amount;
  final String? currencyCode;
  final String? status;
  final String? transactionReference;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  TopUpHistoryModel({
    this.id,
    this.walletId,
    this.userId,
    this.orderId,
    this.storeId,
    this.transactionType,
    this.paymentMethod,
    this.amount,
    this.currencyCode,
    this.status,
    this.transactionReference,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory TopUpHistoryModel.fromJson(Map<String, dynamic> json) {
    return TopUpHistoryModel(
      id: json['id'],
      walletId: json['wallet_id'],
      userId: json['user_id'],
      orderId: json['order_id'],
      storeId: json['store_id'],
      transactionType: json['transaction_type'],
      paymentMethod: json['payment_method'],
      amount: json['amount'],
      currencyCode: json['currency_code'],
      status: json['status'],
      transactionReference: json['transaction_reference'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  TopUpHistoryModel copyWith({
    int? id,
    int? walletId,
    int? userId,
    dynamic orderId,
    dynamic storeId,
    String? transactionType,
    String? paymentMethod,
    String? amount,
    String? currencyCode,
    String? status,
    String? transactionReference,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return TopUpHistoryModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      storeId: storeId ?? this.storeId,
      transactionType: transactionType ?? this.transactionType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      transactionReference: transactionReference ?? this.transactionReference,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
