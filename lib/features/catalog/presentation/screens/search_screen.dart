import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/bundle.dart';
import '../providers/catalog_providers.dart';
import '../widgets/bundle_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String query = ref.watch(searchQueryProvider);
    final AsyncValue<List<Bundle>> resultsAsync = ref.watch(searchResultsProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Search bundles')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppTextField(
              label: 'Search',
              controller: _controller,
              hintText: 'Try "grocery" or "snacks"',
              prefixIcon: Icons.search_rounded,
              autofocus: true,
              onChanged: _onChanged,
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: _buildResults(query, resultsAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(String query, AsyncValue<List<Bundle>> resultsAsync) {
    if (query.trim().length < 2) {
      return const EmptyStateWidget(
        icon: Icons.search_rounded,
        title: 'Search for a bundle',
        message: 'Type at least 2 characters to see results.',
      );
    }

    return resultsAsync.when(
      loading: () => ListView.builder(
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) => const SkeletonListTile(),
      ),
      error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
        failure: error is Failure ? error : const UnexpectedFailure(),
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (List<Bundle> bundles) {
        if (bundles.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off_rounded,
            title: 'No bundles found',
            message: 'Nothing matched "$query" — try a different search term.',
          );
        }
        return GridView.builder(
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
    );
  }
}
