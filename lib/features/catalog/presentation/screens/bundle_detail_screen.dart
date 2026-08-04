import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/widgets/quantity_stepper.dart';
import '../../domain/entities/bundle.dart';
import '../providers/catalog_providers.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class BundleDetailScreen extends ConsumerStatefulWidget {
  const BundleDetailScreen({required this.bundleId, super.key});

  final String bundleId;

  @override
  ConsumerState<BundleDetailScreen> createState() => _BundleDetailScreenState();
}

class _BundleDetailScreenState extends ConsumerState<BundleDetailScreen> {
  int _quantity = 1;

  Future<void> _addToCart(Bundle bundle) async {
    final CartItem item = CartItem(
      bundleId: bundle.id,
      name: bundle.name,
      priceRupees: bundle.priceRupees,
      rewardValueRupees: bundle.rewardValueRupees,
      quantity: _quantity,
      imageUrl: bundle.imageUrl,
    );
    await ref.read(cartControllerProvider.notifier).addToCart(item);
    if (!mounted) return;

    final AsyncValue<List<CartItem>> cartState = ref.read(cartControllerProvider);
    if (cartState.hasError) {
      final Object error = cartState.error!;
      AppSnackbar.error(
        context,
        error is Failure ? error.message : 'Could not add to cart.',
      );
      return;
    }

    AppSnackbar.success(context, 'Added to cart');
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Bundle> bundleAsync =
        ref.watch(bundleByIdProvider(widget.bundleId));

    return AppScaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push(RouteNames.cart),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: bundleAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
          failure: error is Failure ? error : const UnexpectedFailure(),
          onRetry: () => ref.invalidate(bundleByIdProvider(widget.bundleId)),
        ),
        data: (Bundle bundle) => _DetailBody(
          bundle: bundle,
          quantity: _quantity,
          onQuantityChanged: (int q) => setState(() => _quantity = q),
          onAddToCart: () => _addToCart(bundle),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.bundle,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final Bundle bundle;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 4 / 3,
                child: bundle.imageUrl == null || bundle.imageUrl!.isEmpty
                    ? Container(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: scheme.outline,
                        ),
                      )
                    : CachedNetworkImage(imageUrl: bundle.imageUrl!, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(bundle.name, style: text.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _rupeeFormat.format(bundle.priceRupees),
                      style: text.headlineSmall?.copyWith(color: scheme.primary),
                    ),
                    if (bundle.hasReward) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      InfoBanner(
                        message:
                            '+${_rupeeFormat.format(bundle.rewardValueRupees)} in rewards with this bundle',
                        icon: Icons.card_giftcard_rounded,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Text('About this bundle', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      bundle.description.isEmpty
                          ? 'No description available yet.'
                          : bundle.description,
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _AddToCartBar(
          quantity: quantity,
          onQuantityChanged: onQuantityChanged,
          onAddToCart: onAddToCart,
        ),
      ],
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              QuantityStepper(quantity: quantity, onChanged: onQuantityChanged),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppButton(label: 'Add to Cart', onPressed: onAddToCart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
