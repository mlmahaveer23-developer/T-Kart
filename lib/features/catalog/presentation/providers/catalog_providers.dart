import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/catalog_remote_data_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/entities/bundle.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/usecases/get_bundle_by_id_usecase.dart';
import '../../domain/usecases/get_bundles_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_featured_bundles_usecase.dart';
import '../../domain/usecases/search_bundles_usecase.dart';

final Provider<CatalogRemoteDataSource> catalogRemoteDataSourceProvider =
    Provider<CatalogRemoteDataSource>(
  (Ref ref) => CatalogRemoteDataSourceImpl(ref.watch(supabaseClientProvider)),
);

final Provider<CatalogRepository> catalogRepositoryProvider =
    Provider<CatalogRepository>(
  (Ref ref) => CatalogRepositoryImpl(
    remoteDataSource: ref.watch(catalogRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final Provider<GetCategoriesUseCase> getCategoriesUseCaseProvider =
    Provider<GetCategoriesUseCase>(
  (Ref ref) => GetCategoriesUseCase(ref.watch(catalogRepositoryProvider)),
);

final Provider<GetFeaturedBundlesUseCase> getFeaturedBundlesUseCaseProvider =
    Provider<GetFeaturedBundlesUseCase>(
  (Ref ref) => GetFeaturedBundlesUseCase(ref.watch(catalogRepositoryProvider)),
);

final Provider<GetBundlesUseCase> getBundlesUseCaseProvider =
    Provider<GetBundlesUseCase>(
  (Ref ref) => GetBundlesUseCase(ref.watch(catalogRepositoryProvider)),
);

final Provider<SearchBundlesUseCase> searchBundlesUseCaseProvider =
    Provider<SearchBundlesUseCase>(
  (Ref ref) => SearchBundlesUseCase(ref.watch(catalogRepositoryProvider)),
);

final Provider<GetBundleByIdUseCase> getBundleByIdUseCaseProvider =
    Provider<GetBundleByIdUseCase>(
  (Ref ref) => GetBundleByIdUseCase(ref.watch(catalogRepositoryProvider)),
);

// ---- Data providers consumed directly by screens ----

final FutureProvider<List<Category>> categoriesProvider =
    FutureProvider<List<Category>>((Ref ref) async {
  final result = await ref.watch(getCategoriesUseCaseProvider).call();
  return result.fold((failure) => throw failure, (categories) => categories);
});

final FutureProvider<List<Bundle>> featuredBundlesProvider =
    FutureProvider<List<Bundle>>((Ref ref) async {
  final result = await ref.watch(getFeaturedBundlesUseCaseProvider).call();
  return result.fold((failure) => throw failure, (bundles) => bundles);
});

/// Keyed by category id; `null` means "All categories".
final FutureProviderFamily<List<Bundle>, String?> bundlesByCategoryProvider =
    FutureProvider.family<List<Bundle>, String?>((Ref ref, String? categoryId) async {
  final result =
      await ref.watch(getBundlesUseCaseProvider).call(categoryId: categoryId);
  return result.fold((failure) => throw failure, (bundles) => bundles);
});

final FutureProviderFamily<Bundle, String> bundleByIdProvider =
    FutureProvider.family<Bundle, String>((Ref ref, String id) async {
  final result = await ref.watch(getBundleByIdUseCaseProvider).call(id);
  return result.fold((failure) => throw failure, (bundle) => bundle);
});

/// Currently selected category filter on the Home screen. `null` = All.
final StateProvider<String?> selectedCategoryIdProvider =
    StateProvider<String?>((Ref ref) => null);

// ---- Search ----

final AutoDisposeStateProvider<String> searchQueryProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');

final AutoDisposeFutureProvider<List<Bundle>> searchResultsProvider =
    FutureProvider.autoDispose<List<Bundle>>((Ref ref) async {
  final String query = ref.watch(searchQueryProvider).trim();
  if (query.length < 2) return <Bundle>[];
  final result = await ref.watch(searchBundlesUseCaseProvider).call(query);
  return result.fold((failure) => throw failure, (bundles) => bundles);
});
