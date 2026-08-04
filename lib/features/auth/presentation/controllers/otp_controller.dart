import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

/// Drives the OTP-verification screen: verifying the code and
/// re-sending it. On successful verification, Supabase persists the
/// session itself — this controller doesn't need to store anything;
/// the router picks up the new session via [appAuthStateProvider].
class OtpController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<AppUser?> verify({required String phone, required String otp}) async {
    state = const AsyncLoading<void>();
    final result =
        await ref.read(verifyOtpUseCaseProvider).call(phone: phone, otp: otp);

    return result.fold(
      (Failure failure) {
        state = AsyncError<void>(failure, StackTrace.current);
        return null;
      },
      (AppUser user) {
        state = const AsyncData<void>(null);
        return user;
      },
    );
  }

  Future<bool> resend(String phone) async {
    final result = await ref.read(sendOtpUseCaseProvider).call(phone: phone);
    return result.isRight();
  }
}

final AutoDisposeAsyncNotifierProvider<OtpController, void> otpControllerProvider =
    AutoDisposeAsyncNotifierProvider<OtpController, void>(OtpController.new);

/// Resend-cooldown countdown (seconds). Kept separate from
/// [OtpController]'s async state since it's a plain timer, not a
/// network action.
class ResendCooldownNotifier extends AutoDisposeNotifier<int> {
  Timer? _timer;
  static const int _cooldownSeconds = 30;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    _start();
    return _cooldownSeconds;
  }

  void _start() {
    _timer?.cancel();
    state = _cooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (state <= 1) {
        t.cancel();
        state = 0;
      } else {
        state = state - 1;
      }
    });
  }

  void restart() => _start();
}

final AutoDisposeNotifierProvider<ResendCooldownNotifier, int>
    resendCooldownProvider =
    AutoDisposeNotifierProvider<ResendCooldownNotifier, int>(
  ResendCooldownNotifier.new,
);
