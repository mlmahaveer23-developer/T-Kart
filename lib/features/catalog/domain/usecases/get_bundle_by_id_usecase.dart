import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bundle.dart';
import '../repositories/catalog_repository.dart';

class GetBundleByIdUseCase {
  const GetBundleByIdUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, Bundle>> call(String id) =>
      _repository.getBundleById(id);
}
