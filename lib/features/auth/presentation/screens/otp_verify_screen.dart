import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/otp_controller.dart';
import '../../domain/entities/app_user.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({required this.phone, super.key});

  final String phone;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  String? _errorText;

  Future<void> _verify(String code) async {
    setState(() => _errorText = null);
    final AppUser? user = await ref
        .read(otpControllerProvider.notifier)
        .verify(phone: widget.phone, otp: code);

    if (user != null && mounted) {
      context.go(RouteNames.home);
    }
  }

  Future<void> _resend() async {
    final bool ok =
        await ref.read(otpControllerProvider.notifier).resend(widget.phone);
    if (!mounted) return;
    if (ok) {
      ref.read(resendCooldownProvider.notifier).restart();
      AppSnackbar.success(context, 'Code resent to ${widget.phone}');
    } else {
      AppSnackbar.error(context, 'Could not resend the code. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int cooldown = ref.watch(resendCooldownProvider);

    ref.listen(otpControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (Object error, StackTrace stackTrace) {
          setState(() {
            _errorText =
                error is Failure ? error.message : 'Verification failed.';
          });
        },
      );
    });

    final bool isVerifying = ref.watch(otpControllerProvider).isLoading;

    return AppScaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Enter the code', style: text.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We sent a 6-digit code to ${widget.phone}',
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              OtpInputField(
                length: 6,
                errorText: _errorText,
                onCompleted: _verify,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (isVerifying) const AppLoadingIndicator(),
              const Spacer(),
              Center(
                child: cooldown > 0
                    ? Text(
                        'Resend code in ${cooldown}s',
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                      )
                    : AppButton(
                        label: 'Resend code',
                        variant: AppButtonVariant.text,
                        expand: false,
                        onPressed: _resend,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
