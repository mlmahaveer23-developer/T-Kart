import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/router/route_names.dart';
import '../controllers/login_controller.dart';

/// Phone-first login — matches how commerce apps are actually used
/// across tier-2/3 India, where email addresses are often secondary or
/// unused, but everyone has an SMS-reachable mobile number.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String raw = _phoneController.text.trim();
    final String? validationError = Validators.indianPhone(raw);
    setState(() => _errorText = validationError);
    if (validationError != null) return;

    final String e164Phone = '+91$raw';
    final bool success =
        await ref.read(loginControllerProvider.notifier).sendOtp(e164Phone);

    if (success && mounted) {
      context.push(RouteNames.otpVerify, extra: e164Phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    ref.listen(loginControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (Object error, StackTrace stackTrace) {
          final String message =
              error is Failure ? error.message : 'Something went wrong.';
          AppSnackbar.error(context, message);
        },
      );
    });

    final bool isLoading = ref.watch(loginControllerProvider).isLoading;

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Enter your mobile number', style: text.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "We'll send a one-time code to verify it's you.",
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Mobile number',
                controller: _phoneController,
                hintText: '98765 43210',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                errorText: _errorText,
                prefixIcon: Icons.phone_android_rounded,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Send OTP',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
