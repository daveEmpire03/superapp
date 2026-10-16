import 'package:equatable/equatable.dart';

/// The five roles the backend can assign to a user.
/// Backend sends role as an UPPERCASE string (e.g. "CUSTOMER", "RIDER").
enum UserRole {
  customer,
  admin,
  storeManager,
  staff,
  rider;

  static UserRole fromString(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'STORE_MANAGER':
        return UserRole.storeManager;
      case 'STAFF':
        return UserRole.staff;
      case 'RIDER':
        return UserRole.rider;
      case 'CUSTOMER':
      default:
        return UserRole.customer;
    }
  }
}

class UserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  // Kept for compatibility with existing Bokku UI.
  // These can later move into dedicated profile/loyalty features.
  final String avatarUrl;
  final double walletBalance;
  final int loyaltyPoints;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    this.avatarUrl = '',
    this.walletBalance = 0,
    this.loyaltyPoints = 0,
  });

  String get customerId => id;

  String get fullName {
    final name = '$firstName $lastName'.trim();

    if (name.isNotEmpty) {
      return name;
    }

    return email;
  }

  // ---------------------------------------------------------------------------
  // Role helpers — derived from the raw `role` string returned by the backend.
  // Use these everywhere instead of comparing `role == 'CUSTOMER'` inline.
  // ---------------------------------------------------------------------------

  UserRole get roleEnum => UserRole.fromString(role);

  bool get isCustomer => roleEnum == UserRole.customer;
  bool get isRider => roleEnum == UserRole.rider;
  bool get isStoreStaff =>
      roleEnum == UserRole.staff || roleEnum == UserRole.storeManager;
  bool get isAdmin => roleEnum == UserRole.admin;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phoneNumber,
    role,
    isEmailVerified,
    isPhoneVerified,
    avatarUrl,
    walletBalance,
    loyaltyPoints,
  ];
}
