import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/bundle.dart';
import '../../domain/entities/category.dart';
import '../providers/catalog_providers.dart';
import '../widgets/bundle_card.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    final String? categoryId = ref.read(selectedCategoryIdProvider);
    ref
      ..invalidate(categoriesProvider)
      ..invalidate(featuredBundlesProvider)
      ..invalidate(bundlesByCategoryProvider(categoryId));
    await Future.wait<Object?>(<Future<Object?>>[
      ref.read(categoriesProvider.future),
      ref.read(featuredBundlesProvider.future),
      ref.read(bundlesByCategoryProvider(categoryId).future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final String? selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Tribhuban Concepts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search bundles',
            onPressed: () => context.push(RouteNames.search),
          ),
          _CartAction(),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () => context.push(RouteNames.profile),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: InfoBanner(
                message: '₹2,500 in rewards on the ₹4,999 Grocery Bundle',
                onTap: () => context.push(RouteNames.rewards),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SectionHeader(
                title: 'Categories',
                actionLabel: selectedCategoryId == null ? null : 'Clear',
                onAction: selectedCategoryId == null
                    ? null
                    : () => ref.read(selectedCategoryIdProvider.notifier).state = null,
              ),
            ),
            _CategoriesRow(selectedCategoryId: selectedCategoryId),

            const SizedBox(height: AppSpacing.xl),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SectionHeader(title: 'Featured bundles'),
            ),
            const _FeaturedBundlesRow(),

            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                selectedCategoryId == null ? 'All bundles' : 'Bundles',
                style: text.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _BundleGrid(categoryId: selectedCategoryId),
          ],
        ),
      ),
    );
  }
}

class _CartAction extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int count = ref.watch(cartItemCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: 'Cart',
          onPressed: () => context.push(RouteNames.cart),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoriesRow extends ConsumerWidget {
  const _CategoriesRow({required this.selectedCategoryId});

  final String? selectedCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(categoriesProvider);

    return SizedBox(
      height: 40,
      child: categoriesAsync.when(
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: List<Widget>.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: SkeletonBox(
                width: 90,
                height: 32,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
        ),
        error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
        data: (List<Category> categories) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: <Widget>[
            CategoryChip(
              label: 'All',
              selected: selectedCategoryId == null,
              onTap: () => ref.read(selectedCategoryIdProvider.notifier).state = null,
            ),
            for (final Category category in categories)
              CategoryChip(
                category: category,
                label: category.name,
                selected: selectedCategoryId == category.id,
                onTap: () =>
                    ref.read(selectedCategoryIdProvider.notifier).state = category.id,
              ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedBundlesRow extends ConsumerWidget {
  const _FeaturedBundlesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Bundle>> featuredAsync = ref.watch(featuredBundlesProvider);

    return SizedBox(
      height: 210,
      child: featuredAsync.when(
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: List<Widget>.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: SkeletonBox(
                width: 180,
                height: 200,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
        ),
        error: (Object error, StackTrace stackTrace) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(featuredBundlesProvider),
            child: const Text('Could not load featured bundles — tap to retry'),
          ),
        ),
        data: (List<Bundle> bundles) {
          if (bundles.isEmpty) return const SizedBox.shrink();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: bundles.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) => BundleCard(
              bundle: bundles[index],
              width: 180,
              onTap: () => context.push('${RouteNames.bundleDetail}/${bundles[index].id}'),
            ),
          );
        },
      ),
    );
  }
}

class _BundleGrid extends ConsumerWidget {
  const _BundleGrid({required this.categoryId});

  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Bundle>> bundlesAsync =
        ref.watch(bundlesByCategoryProvider(categoryId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: bundlesAsync.when(
        loading: () => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (BuildContext context, int index) => const SkeletonBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
          failure: error is Failure ? error : const UnexpectedFailure(),
          onRetry: () => ref.invalidate(bundlesByCategoryProvider(categoryId)),
        ),
        data: (List<Bundle> bundles) {
          if (bundles.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'No bundles here yet',
              message: 'Check back soon, or try a different category.',
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bundles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (BuildContext context, int index) => BundleCard(
              bundle: bundles[index],
              onTap: () => context.push('${RouteNames.bundleDetail}/${bundles[index].id}'),
            ),
          );
        },
      ),
    );
  }
}
