// class ParcelDetails {
//   final Parcel? parcel;

//   ParcelDetails({this.parcel});

//   factory ParcelDetails.fromJson(Map<String, dynamic> json) {
//     return ParcelDetails(
//       parcel: json['parcel'] != null ? Parcel.fromJson(json['parcel']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'parcel': parcel?.toJson(),
//     };
//   }
// }

// class Parcel {
//   final int? pbId;
//   final int? userId;
//   final int? addressId;
//   final String? pbType;
//   final String? pbNumber;
//   final String? receiverName;
//   final String? receiverAddress;
//   final String? receiverLat;
//   final String? receiverLong;
//   final String? receiverMobile;
//   final String? receiverStreet;
//   final String? receiverHouse;
//   final String? receiverFloor;
//   final String? whoPay;
//   final String? payMethod;
//   final String? deliveryCharge;
//   final String? status;
//   final String? createdAt;
//   final String? updatedAt;

//   final User? user;
//   final Address? address;
//   final List<DeliveryAssignment> deliveryAssignments;

//   Parcel({
//     this.pbId,
//     this.userId,
//     this.addressId,
//     this.pbType,
//     this.pbNumber,
//     this.receiverName,
//     this.receiverAddress,
//     this.receiverLat,
//     this.receiverLong,
//     this.receiverMobile,
//     this.receiverStreet,
//     this.receiverHouse,
//     this.receiverFloor,
//     this.whoPay,
//     this.payMethod,
//     this.deliveryCharge,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.user,
//     this.address,
//     this.deliveryAssignments = const [],
//   });

//   factory Parcel.fromJson(Map<String, dynamic> json) {
//     return Parcel(
//       pbId: json['pb_id'],
//       userId: json['user_id'],
//       addressId: json['address_id'],
//       pbType: json['pb_type'],
//       pbNumber: json['pb_number'],
//       receiverName: json['rc_name'],
//       receiverAddress: json['rc_address'],
//       receiverLat: json['rc_lat'],
//       receiverLong: json['rc_long'],
//       receiverMobile: json['rc_mobile'],
//       receiverStreet: json['rc_street'],
//       receiverHouse: json['rc_house'],
//       receiverFloor: json['rc_floor'],
//       whoPay: json['pb_whoPay'],
//       payMethod: json['pb_payMethod'],
//       deliveryCharge: json['pb_deliveryCharge'],
//       status: json['pb_status'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       user: json['user'] != null ? User.fromJson(json['user']) : null,
//       address:
//           json['address'] != null ? Address.fromJson(json['address']) : null,
//       deliveryAssignments: _parseAssignments(json['delivery_boy_assignments']),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'pb_id': pbId,
//         'user_id': userId,
//         'address_id': addressId,
//         'pb_type': pbType,
//         'pb_number': pbNumber,
//         'rc_name': receiverName,
//         'rc_address': receiverAddress,
//         'rc_lat': receiverLat,
//         'rc_long': receiverLong,
//         'rc_mobile': receiverMobile,
//         'rc_street': receiverStreet,
//         'rc_house': receiverHouse,
//         'rc_floor': receiverFloor,
//         'pb_whoPay': whoPay,
//         'pb_payMethod': payMethod,
//         'pb_deliveryCharge': deliveryCharge,
//         'pb_status': status,
//         'created_at': createdAt,
//         'updated_at': updatedAt,
//         'user': user?.toJson(),
//         'address': address?.toJson(),
//         'delivery_boy_assignments':
//             deliveryAssignments.map((e) => e.toJson()).toList(),
//       };

//   static List<DeliveryAssignment> _parseAssignments(dynamic value) {
//     if (value is! Iterable) return const [];
//     return value
//         .whereType<Map<String, dynamic>>()
//         .map(DeliveryAssignment.fromJson)
//         .toList();
//   }
// }

// class User {
//   final int? id;
//   final String? name;
//   final String? email;
//   final String? mobile;

//   User({
//     this.id,
//     this.name,
//     this.email,
//     this.mobile,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       mobile: json['mobile'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'email': email,
//         'mobile': mobile,
//       };
// }

// class Address {
//   final int? id;
//   final String? addressLine1;
//   final String? addressLine2;
//   final String? city;
//   final String? state;
//   final String? zipcode;

//   Address({
//     this.id,
//     this.addressLine1,
//     this.addressLine2,
//     this.city,
//     this.state,
//     this.zipcode,
//   });

//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       id: json['id'],
//       addressLine1: json['address_line1'],
//       addressLine2: json['address_line2'],
//       city: json['city'],
//       state: json['state'],
//       zipcode: json['zipcode'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'address_line1': addressLine1,
//         'address_line2': addressLine2,
//         'city': city,
//         'state': state,
//         'zipcode': zipcode,
//       };
// }

// class DeliveryAssignment {
//   final int? id;
//   final int? parcelId;
//   final int? deliveryBoyId;
//   final String? status;
//   final String? assignedAt;
//   final String? completedAt;
//   final DeliveryBoy? deliveryBoy;

//   DeliveryAssignment({
//     this.id,
//     this.parcelId,
//     this.deliveryBoyId,
//     this.status,
//     this.assignedAt,
//     this.completedAt,
//     this.deliveryBoy,
//   });

//   factory DeliveryAssignment.fromJson(Map<String, dynamic> json) {
//     return DeliveryAssignment(
//       id: json['id'],
//       parcelId: json['parcel_id'],
//       deliveryBoyId: json['delivery_boy_id'],
//       status: json['status'],
//       assignedAt: json['assigned_at'],
//       completedAt: json['completed_at'],
//       deliveryBoy: json['delivery_boy'] != null
//           ? DeliveryBoy.fromJson(json['delivery_boy'])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'parcel_id': parcelId,
//         'delivery_boy_id': deliveryBoyId,
//         'status': status,
//         'assigned_at': assignedAt,
//         'completed_at': completedAt,
//         'delivery_boy': deliveryBoy?.toJson(),
//       };
// }

// class DeliveryBoy {
//   final int? id;
//   final String? fullName;
//   final String? vehicleType;
//   final String? status;

//   DeliveryBoy({
//     this.id,
//     this.fullName,
//     this.vehicleType,
//     this.status,
//   });

//   factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
//     return DeliveryBoy(
//       id: json['id'],
//       fullName: json['full_name'],
//       vehicleType: json['vehicle_type'],
//       status: json['status'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'full_name': fullName,
//         'vehicle_type': vehicleType,
//         'status': status,
//       };
// }




class ParcelDetails {
  final Parcel? parcel;

  ParcelDetails({this.parcel});

  factory ParcelDetails.fromJson(Map<String, dynamic> json) {
    return ParcelDetails(
      parcel: json['parcel'] != null ? Parcel.fromJson(json['parcel']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parcel': parcel?.toJson(),
    };
  }
}

class Parcel {
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
  final String? payMethod;
  final String? deliveryCharge;
  final String? status;
  final String? assignedAt; // Added
  final String? outForDelivery; // Added
  final String? completedAt; // Added
  final String? cancelledAt; // Added
  final String? createdAt;
  final String? updatedAt;

  final User? user;
  final Address? address;
  final List<DeliveryAssignment> deliveryAssignments;

  Parcel({
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
    this.payMethod,
    this.deliveryCharge,
    this.status,
    this.assignedAt,
    this.outForDelivery,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.address,
    this.deliveryAssignments = const [],
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
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
      payMethod: json['pb_payMethod'],
      deliveryCharge: json['pb_deliveryCharge'],
      status: json['pb_status'],
      assignedAt: json['assigned_at'],
      outForDelivery: json['out_for_delivery'],
      completedAt: json['completed_at'],
      cancelledAt: json['cancelled_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      deliveryAssignments: _parseAssignments(json['delivery_boy_assignments']),
    );
  }

  Map<String, dynamic> toJson() => {
        'pb_id': pbId,
        'user_id': userId,
        'address_id': addressId,
        'pb_type': pbType,
        'pb_number': pbNumber,
        'rc_name': receiverName,
        'rc_address': receiverAddress,
        'rc_lat': receiverLat,
        'rc_long': receiverLong,
        'rc_mobile': receiverMobile,
        'rc_street': receiverStreet,
        'rc_house': receiverHouse,
        'rc_floor': receiverFloor,
        'pb_whoPay': whoPay,
        'pb_payMethod': payMethod,
        'pb_deliveryCharge': deliveryCharge,
        'pb_status': status,
        'assigned_at': assignedAt,
        'out_for_delivery': outForDelivery,
        'completed_at': completedAt,
        'cancelled_at': cancelledAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'user': user?.toJson(),
        'address': address?.toJson(),
        'delivery_boy_assignments':
            deliveryAssignments.map((e) => e.toJson()).toList(),
      };

  static List<DeliveryAssignment> _parseAssignments(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(DeliveryAssignment.fromJson)
        .toList();
  }
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? profileImage; // Added

  User({this.id, this.name, this.email, this.mobile, this.profileImage});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'mobile': mobile,
        'profile_image': profileImage,
      };
}

class Address {
  final int? id;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? zipcode;
  final dynamic latitude;  // Changed to dynamic to handle high precision doubles from JSON
  final dynamic longitude;

  Address({
    this.id,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.zipcode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      zipcode: json['zipcode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'zipcode': zipcode,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class DeliveryAssignment {
  final int? id;
  final int? parcelId;
  final int? deliveryBoyId;
  final String? status;
  final String? assignedAt;
  final String? outForDelivery; // Added
  final String? completedAt;
  final String? totalEarnings; // Added
  final DeliveryBoy? deliveryBoy;

  DeliveryAssignment({
    this.id,
    this.parcelId,
    this.deliveryBoyId,
    this.status,
    this.assignedAt,
    this.outForDelivery,
    this.completedAt,
    this.totalEarnings,
    this.deliveryBoy,
  });

  factory DeliveryAssignment.fromJson(Map<String, dynamic> json) {
    return DeliveryAssignment(
      id: json['id'],
      parcelId: json['parcel_id'],
      deliveryBoyId: json['delivery_boy_id'],
      status: json['status'],
      assignedAt: json['assigned_at'],
      outForDelivery: json['out_for_delivery'],
      completedAt: json['completed_at'],
      totalEarnings: json['total_earnings'],
      deliveryBoy: json['delivery_boy'] != null
          ? DeliveryBoy.fromJson(json['delivery_boy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'parcel_id': parcelId,
        'delivery_boy_id': deliveryBoyId,
        'status': status,
        'assigned_at': assignedAt,
        'out_for_delivery': outForDelivery,
        'completed_at': completedAt,
        'total_earnings': totalEarnings,
        'delivery_boy': deliveryBoy?.toJson(),
      };
}

class DeliveryBoy {
  final int? id;
  final String? fullName;
  final String? vehicleType;
  final String? status;
  final String? driverLicenseNumber; // Added

  DeliveryBoy({
    this.id,
    this.fullName,
    this.vehicleType,
    this.status,
    this.driverLicenseNumber,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      id: json['id'],
      fullName: json['full_name'],
      vehicleType: json['vehicle_type'],
      status: json['status'],
      driverLicenseNumber: json['driver_license_number'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'vehicle_type': vehicleType,
        'status': status,
        'driver_license_number': driverLicenseNumber,
      };
}
