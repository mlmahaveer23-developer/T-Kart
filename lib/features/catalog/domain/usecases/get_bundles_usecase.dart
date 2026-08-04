import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bundle.dart';
import '../repositories/catalog_repository.dart';

class GetBundlesUseCase {
  const GetBundlesUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, List<Bundle>>> call({String? categoryId}) =>
      _repository.getBundles(categoryId: categoryId);
}
