import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/bundle.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required CatalogRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final CatalogRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return Left<Failure, T>(const NetworkFailure());
    }
    try {
      return Right<Failure, T>(await action());
    } on ServerException catch (e) {
      return Left<Failure, T>(ServerFailure(e.message));
    } catch (_) {
      return Left<Failure, T>(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() =>
      _guard(_remoteDataSource.getCategories);

  @override
  Future<Either<Failure, List<Bundle>>> getFeaturedBundles() =>
      _guard(_remoteDataSource.getFeaturedBundles);

  @override
  Future<Either<Failure, List<Bundle>>> getBundles({String? categoryId}) =>
      _guard(() => _remoteDataSource.getBundles(categoryId: categoryId));

  @override
  Future<Either<Failure, List<Bundle>>> searchBundles(String query) =>
      _guard(() => _remoteDataSource.searchBundles(query));

  @override
  Future<Either<Failure, Bundle>> getBundleById(String id) =>
      _guard(() => _remoteDataSource.getBundleById(id));
}
