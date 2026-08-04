import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/catalog_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, List<Category>>> call() => _repository.getCategories();
}
