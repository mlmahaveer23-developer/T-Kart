import 'package:equatable/equatable.dart';

/// Domain-layer representation of an authenticated customer. Deliberately
/// minimal in Phase 2 — profile fields (name, saved addresses, etc.)
/// belong to the Profile feature, not Auth.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.phone,
    this.email,
    this.createdAt,
  });

  final String id;
  final String phone;
  final String? email;
  final DateTime? createdAt;

  @override
  List<Object?> get props => <Object?>[id, phone, email, createdAt];
}
