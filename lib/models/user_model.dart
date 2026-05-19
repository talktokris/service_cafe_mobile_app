class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.memberType,
    required this.userType,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.gender,
    this.country,
    this.referralCode,
    this.referralCount = 0,
    this.walletBalance = 0,
    this.activeStatus = 0,
  });

  final int id;
  final String name;
  final String email;
  final String memberType;
  final String userType;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final String? gender;
  final String? country;
  final String? referralCode;
  final int referralCount;
  final double walletBalance;
  final int activeStatus;

  bool get isPaid => memberType == 'paid';
  bool get isFree => memberType == 'free';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      memberType: json['member_type']?.toString() ?? 'free',
      userType: json['user_type']?.toString() ?? 'member',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      country: json['country']?.toString(),
      referralCode: json['referral_code']?.toString(),
      referralCount: (json['referral_count'] as num?)?.toInt() ?? 0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      activeStatus: (json['active_status'] as num?)?.toInt() ?? 0,
    );
  }
}
