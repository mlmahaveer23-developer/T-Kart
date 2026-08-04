import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

/// Drives the Profile screen's "Sign Out" action. On success, the
/// router picks up the auth-state change reactively (via
/// `GoRouterRefreshStream` watching Supabase's auth stream — see
/// `core/router/app_router.dart`) and bounces the user to Login on its
/// own; this controller doesn't need to navigate.
class SignOutController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signOut() async {
    state = const AsyncLoading<void>();
    final result = await ref.read(signOutUseCaseProvider).call();
    return result.fold(
      (failure) {
        state = AsyncError<void>(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData<void>(null);
        return true;
      },
    );
  }
}

final AutoDisposeAsyncNotifierProvider<SignOutController, void>
    signOutControllerProvider =
    AutoDisposeAsyncNotifierProvider<SignOutController, void>(
  SignOutController.new,
);
