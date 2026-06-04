class DeliveryZoneModel {
  final int id;
  final String name;
  final String slug;
  final String centerLatitude;
  final String centerLongitude;
  final double radiusKm;
  final List<BoundaryPoint> boundaryJson;
  final bool rushDeliveryEnabled;
  final int deliveryTimePerKm;
  final int? rushDeliveryTimePerKm;
  final int? rushDeliveryCharges;
  final int regularDeliveryCharges;
  final int? freeDeliveryAmount;
  final int? distanceBasedDeliveryCharges;
  final int? perStoreDropOffFee;
  final int? handlingCharges;
  final int bufferTime;
  final String status;
  final String? deliveryBoyBaseFee;
  final String? deliveryBoyPerStorePickupFee;
  final String? deliveryBoyDistanceBasedFee;
  final String? deliveryBoyPerOrderIncentive;
  final String createdAt;
  final String updatedAt;

  DeliveryZoneModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusKm,
    required this.boundaryJson,
    required this.rushDeliveryEnabled,
    required this.deliveryTimePerKm,
    this.rushDeliveryTimePerKm,
    this.rushDeliveryCharges,
    required this.regularDeliveryCharges,
    this.freeDeliveryAmount,
    this.distanceBasedDeliveryCharges,
    this.perStoreDropOffFee,
    this.handlingCharges,
    required this.bufferTime,
    required this.status,
    this.deliveryBoyBaseFee,
    this.deliveryBoyPerStorePickupFee,
    this.deliveryBoyDistanceBasedFee,
    this.deliveryBoyPerOrderIncentive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      centerLatitude: json['center_latitude']?.toString() ?? '0',
      centerLongitude: json['center_longitude']?.toString() ?? '0',
      radiusKm: (json['radius_km'] is int)
          ? (json['radius_km'] as int).toDouble()
          : (json['radius_km'] ?? 0.0),
      boundaryJson: (json['boundary_json'] as List?)
              ?.map((e) => BoundaryPoint.fromJson(e))
              .toList() ??
          [],
      rushDeliveryEnabled: json['rush_delivery_enabled'] ?? false,
      deliveryTimePerKm: json['delivery_time_per_km'] ?? 0,
      rushDeliveryTimePerKm: json['rush_delivery_time_per_km'],
      rushDeliveryCharges: json['rush_delivery_charges'],
      regularDeliveryCharges: json['regular_delivery_charges'] ?? 0,
      freeDeliveryAmount: json['free_delivery_amount'],
      distanceBasedDeliveryCharges: json['distance_based_delivery_charges'],
      perStoreDropOffFee: json['per_store_drop_off_fee'],
      handlingCharges: json['handling_charges'],
      bufferTime: json['buffer_time'] ?? 0,
      status: json['status'] ?? 'inactive',
      deliveryBoyBaseFee: json['delivery_boy_base_fee']?.toString(),
      deliveryBoyPerStorePickupFee:
          json['delivery_boy_per_store_pickup_fee']?.toString(),
      deliveryBoyDistanceBasedFee:
          json['delivery_boy_distance_based_fee']?.toString(),
      deliveryBoyPerOrderIncentive:
          json['delivery_boy_per_order_incentive']?.toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'center_latitude': centerLatitude,
      'center_longitude': centerLongitude,
      'radius_km': radiusKm,
      'boundary_json': boundaryJson.map((e) => e.toJson()).toList(),
      'rush_delivery_enabled': rushDeliveryEnabled,
      'delivery_time_per_km': deliveryTimePerKm,
      'rush_delivery_time_per_km': rushDeliveryTimePerKm,
      'rush_delivery_charges': rushDeliveryCharges,
      'regular_delivery_charges': regularDeliveryCharges,
      'free_delivery_amount': freeDeliveryAmount,
      'distance_based_delivery_charges': distanceBasedDeliveryCharges,
      'per_store_drop_off_fee': perStoreDropOffFee,
      'handling_charges': handlingCharges,
      'buffer_time': bufferTime,
      'status': status,
      'delivery_boy_base_fee': deliveryBoyBaseFee,
      'delivery_boy_per_store_pickup_fee': deliveryBoyPerStorePickupFee,
      'delivery_boy_distance_based_fee': deliveryBoyDistanceBasedFee,
      'delivery_boy_per_order_incentive': deliveryBoyPerOrderIncentive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BoundaryPoint {
  final double lat;
  final double lng;

  BoundaryPoint({
    required this.lat,
    required this.lng,
  });

  factory BoundaryPoint.fromJson(Map<String, dynamic> json) {
    return BoundaryPoint(
      lat: (json['lat'] is int)
          ? (json['lat'] as int).toDouble()
          : (json['lat'] ?? 0.0),
      lng: (json['lng'] is int)
          ? (json['lng'] as int).toDouble()
          : (json['lng'] ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class DeliveryZoneListResponse {
  final bool success;
  final String message;
  final DeliveryZoneData data;

  DeliveryZoneListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DeliveryZoneListResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DeliveryZoneData.fromJson(json['data'] ?? {}),
    );
  }
}

class DeliveryZoneData {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<DeliveryZoneModel> data;

  DeliveryZoneData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  factory DeliveryZoneData.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneData(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => DeliveryZoneModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
