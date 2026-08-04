import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../providers/auth_providers.dart';

/// Drives the phone-entry screen. Holds loading/error state for the
/// "Send OTP" action; the screen calls [sendOtp] and reacts to the
/// returned bool for navigation, while `ref.listen`-ing this provider
/// for error snackbars.
class LoginController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial async work — state starts as AsyncData(null) (idle).
  }

  /// Returns true on success (caller should navigate to OTP screen).
  Future<bool> sendOtp(String phoneE164) async {
    state = const AsyncLoading<void>();
    final result =
        await ref.read(sendOtpUseCaseProvider).call(phone: phoneE164);

    return result.fold(
      (Failure failure) {
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

final AutoDisposeAsyncNotifierProvider<LoginController, void>
    loginControllerProvider =
    AutoDisposeAsyncNotifierProvider<LoginController, void>(
  LoginController.new,
);
