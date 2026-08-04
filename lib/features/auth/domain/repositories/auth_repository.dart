import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

/// Contract the data layer must fulfil. Presentation code (controllers)
/// depends only on this abstraction — never on Supabase directly — so
/// the auth backend could be swapped without touching a single screen.
abstract class AuthRepository {
  /// Triggers an SMS OTP to [phone]. [phone] must be in E.164 format
  /// (e.g. `+919876543210`).
  Future<Either<Failure, void>> sendOtp({required String phone});

  /// Verifies [otp] for [phone] and, on success, establishes a Supabase
  /// session (persisted automatically by supabase_flutter).
  Future<Either<Failure, AppUser>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, void>> signOut();

  /// Synchronous snapshot of the current session, if any — used by the
  /// router's redirect logic which cannot await.
  AppUser? get currentUser;

  /// Emits whenever auth state changes (sign-in, sign-out, token
  /// refresh) so the app shell / router can react reactively.
  Stream<AppUser?> get authStateChanges;
}
