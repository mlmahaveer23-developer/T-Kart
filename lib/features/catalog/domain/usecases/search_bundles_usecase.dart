import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bundle.dart';
import '../repositories/catalog_repository.dart';

class SearchBundlesUseCase {
  const SearchBundlesUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, List<Bundle>>> call(String query) =>
      _repository.searchBundles(query);
}
