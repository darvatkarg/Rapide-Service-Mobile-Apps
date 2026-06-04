class Parcel {
  final int? pbId;
  final int? userId;
  final int? addressId;
  final String? pbType;
  final String? pbNumber;
  final String? rcName;
  final String? rcAddress;
  final String? rcLat;
  final String? rcLong;
  final String? rcMobile;
  final String? rcStreet;
  final String? rcHouse;
  final String? rcFloor;
  final String? pbWhoPay;
  final String? pbPayMethod;
  final String? pbDeliveryCharge;
  final String? pbStatus;
  final String? createdAt;
  final String? updatedAt;
  final User? user;
  final dynamic address;
  final List<dynamic>? deliveryBoyAssignments;

  Parcel({
    this.pbId,
    this.userId,
    this.addressId,
    this.pbType,
    this.pbNumber,
    this.rcName,
    this.rcAddress,
    this.rcLat,
    this.rcLong,
    this.rcMobile,
    this.rcStreet,
    this.rcHouse,
    this.rcFloor,
    this.pbWhoPay,
    this.pbPayMethod,
    this.pbDeliveryCharge,
    this.pbStatus,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.address,
    this.deliveryBoyAssignments,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      pbId: json['pb_id'],
      userId: json['user_id'],
      addressId: json['address_id'],
      pbType: json['pb_type'],
      pbNumber: json['pb_number'],
      rcName: json['rc_name'],
      rcAddress: json['rc_address'],
      rcLat: json['rc_lat'],
      rcLong: json['rc_long'],
      rcMobile: json['rc_mobile'],
      rcStreet: json['rc_street'],
      rcHouse: json['rc_house'],
      rcFloor: json['rc_floor'],
      pbWhoPay: json['pb_whoPay'],
      pbPayMethod: json['pb_payMethod'],
      pbDeliveryCharge: json['pb_deliveryCharge'],
      pbStatus: json['pb_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      address: json['address'],
      deliveryBoyAssignments: json['delivery_boy_assignments'] ?? [],
    );
  }
}

class User {
  final int? id;
  final int? storeId;
  final String? mobile;
  final String? referralCode;
  final String? friendsCode;
  final int? rewardPoints;
  final bool? status;
  final String? name;
  final String? email;
  final String? country;
  final String? iso2;
  final String? emailVerifiedAt;
  final String? accessPanel;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? profileImage;
  final List<dynamic>? media;

  User({
    this.id,
    this.storeId,
    this.mobile,
    this.referralCode,
    this.friendsCode,
    this.rewardPoints,
    this.status,
    this.name,
    this.email,
    this.country,
    this.iso2,
    this.emailVerifiedAt,
    this.accessPanel,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.media,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      storeId: json['store_id'],
      mobile: json['mobile'],
      referralCode: json['referral_code'],
      friendsCode: json['friends_code'],
      rewardPoints: json['reward_points'],
      status: json['status'],
      name: json['name'],
      email: json['email'],
      country: json['country'],
      iso2: json['iso_2'],
      emailVerifiedAt: json['email_verified_at'],
      accessPanel: json['access_panel'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      profileImage: json['profile_image'],
      media: json['media'] ?? [],
    );
  }
}
