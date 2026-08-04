import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Segmented OTP entry (one box per digit) with auto-advance and
/// backspace-to-previous-box behavior. Built once here so Phase 2's
/// phone/email verification screen doesn't hand-roll this interaction.
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    required this.length,
    required this.onCompleted,
    super.key,
    this.onChanged,
    this.errorText,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final String combined =
        _controllers.map((TextEditingController c) => c.text).join();
    widget.onChanged?.call(combined);

    if (combined.length == widget.length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(combined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(widget.length, (int index) {
            return SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: Theme.of(context).textTheme.titleLarge,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderSm,
                    borderSide: BorderSide(
                      color: hasError ? scheme.error : Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderSm,
                    borderSide: BorderSide(
                      color: hasError ? scheme.error : scheme.primary,
                      width: 1.6,
                    ),
                  ),
                ),
                onChanged: (String value) => _onChanged(index, value),
              ),
            );
          }),
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.errorText!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }
}
