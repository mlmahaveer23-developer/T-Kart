import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/app_user.dart';

/// Data-layer mapper — the only place that knows about
/// `supabase_flutter`'s `User` shape. Keeps that dependency out of the
/// domain layer entirely.
class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.phone,
    super.email,
    super.createdAt,
  });

  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(
      id: user.id,
      phone: user.phone ?? '',
      email: user.email,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }
}
