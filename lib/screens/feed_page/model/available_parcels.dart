class AvailableParcels {
  final int? pbId;
  final int? userId;
  final int? addressId;
  final String? pbType;
  final String? pbNumber;

  final String? receiverName;
  final String? receiverAddress;
  final String? receiverLat;
  final String? receiverLong;
  final String? receiverMobile;
  final String? receiverStreet;
  final String? receiverHouse;
  final String? receiverFloor;

  final String? whoPay;
  final String? paymentMethod;
  final String? deliveryCharge;

  final String? status;

  final String? createdAt;
  final String? updatedAt;

  AvailableParcels({
    this.pbId,
    this.userId,
    this.addressId,
    this.pbType,
    this.pbNumber,
    this.receiverName,
    this.receiverAddress,
    this.receiverLat,
    this.receiverLong,
    this.receiverMobile,
    this.receiverStreet,
    this.receiverHouse,
    this.receiverFloor,
    this.whoPay,
    this.paymentMethod,
    this.deliveryCharge,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AvailableParcels.fromJson(Map<String, dynamic> json) {
    return AvailableParcels(
      pbId: json['pb_id'],
      userId: json['user_id'],
      addressId: json['address_id'],
      pbType: json['pb_type'],
      pbNumber: json['pb_number'],

      receiverName: json['rc_name'],
      receiverAddress: json['rc_address'],
      receiverLat: json['rc_lat'],
      receiverLong: json['rc_long'],
      receiverMobile: json['rc_mobile'],
      receiverStreet: json['rc_street'],
      receiverHouse: json['rc_house'],
      receiverFloor: json['rc_floor'],

      whoPay: json['pb_whoPay'],
      paymentMethod: json['pb_payMethod'],
      deliveryCharge: json['pb_deliveryCharge'],

      status: json['pb_status'],

      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  AvailableParcels copyWith({
    int? pbId,
    int? userId,
    int? addressId,
    String? pbType,
    String? pbNumber,
    String? receiverName,
    String? receiverAddress,
    String? receiverLat,
    String? receiverLong,
    String? receiverMobile,
    String? receiverStreet,
    String? receiverHouse,
    String? receiverFloor,
    String? whoPay,
    String? paymentMethod,
    String? deliveryCharge,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return AvailableParcels(
      pbId: pbId ?? this.pbId,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      pbType: pbType ?? this.pbType,
      pbNumber: pbNumber ?? this.pbNumber,
      receiverName: receiverName ?? this.receiverName,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      receiverLat: receiverLat ?? this.receiverLat,
      receiverLong: receiverLong ?? this.receiverLong,
      receiverMobile: receiverMobile ?? this.receiverMobile,
      receiverStreet: receiverStreet ?? this.receiverStreet,
      receiverHouse: receiverHouse ?? this.receiverHouse,
      receiverFloor: receiverFloor ?? this.receiverFloor,
      whoPay: whoPay ?? this.whoPay,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}