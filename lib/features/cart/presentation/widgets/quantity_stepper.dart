import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/buttons/app_icon_button.dart';

/// Shared +/- quantity control used on both the bundle detail screen
/// (choosing how many to add) and the cart screen (adjusting an
/// existing line). [min] defaults to 1 so the detail screen can't be
/// decremented to zero — the cart screen passes `min: 0` and treats 0
/// as "remove this line".
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onChanged,
    super.key,
    this.min = 1,
    this.max = 20,
  });

  final int quantity;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderPill,
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIconButton(
            icon: Icons.remove_rounded,
            size: 36,
            iconSize: 16,
            backgroundColor: Colors.transparent,
            onPressed: quantity > min ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          AppIconButton(
            icon: Icons.add_rounded,
            size: 36,
            iconSize: 16,
            backgroundColor: Colors.transparent,
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}
