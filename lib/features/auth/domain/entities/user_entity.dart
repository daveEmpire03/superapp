import 'package:equatable/equatable.dart';

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

  bool get isCustomer => role == 'CUSTOMER';

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
