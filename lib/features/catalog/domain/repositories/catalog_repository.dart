import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bundle.dart';
import '../entities/category.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<Category>>> getCategories();

  Future<Either<Failure, List<Bundle>>> getFeaturedBundles();

  /// Pass null to fetch all bundles regardless of category.
  Future<Either<Failure, List<Bundle>>> getBundles({String? categoryId});

  Future<Either<Failure, List<Bundle>>> searchBundles(String query);

  Future<Either<Failure, Bundle>> getBundleById(String id);
}
