import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Only place in the app that calls `supabase_flutter`'s auth API
/// directly. Converts Supabase's own exceptions into the app's typed
/// `Exception`s so the repository layer has one consistent error
/// vocabulary regardless of backend.
abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);
  Future<UserModel> verifyOtp(String phone, String otp);
  Future<void> signOut();
  UserModel? get currentUser;
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final supabase.SupabaseClient _client;

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (_) {
      throw const UnexpectedException('Could not send verification code.');
    }
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    try {
      final supabase.AuthResponse response = await _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: supabase.OtpType.sms,
      );
      final supabase.User? user = response.user;
      if (user == null) {
        throw const AuthException('Verification failed. Please try again.');
      }
      return UserModel.fromSupabaseUser(user);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  UserModel? get currentUser {
    final supabase.User? user = _client.auth.currentUser;
    return user == null ? null : UserModel.fromSupabaseUser(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map(
      (supabase.AuthState state) {
        final supabase.User? user = state.session?.user;
        return user == null ? null : UserModel.fromSupabaseUser(user);
      },
    );
  }
}
