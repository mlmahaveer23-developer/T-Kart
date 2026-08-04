import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl({
    required AddressRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final AddressRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  Future<Either<Failure, List<Address>>> _guard(
    Future<List<AddressModel>> Function() action,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left<Failure, List<Address>>(NetworkFailure());
    }
    try {
      return Right<Failure, List<Address>>(await action());
    } on AuthException catch (e) {
      return Left<Failure, List<Address>>(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left<Failure, List<Address>>(ServerFailure(e.message));
    } catch (_) {
      return const Left<Failure, List<Address>>(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Address>>> getAddresses() =>
      _guard(_remoteDataSource.getAddresses);

  @override
  Future<Either<Failure, List<Address>>> addAddress(Address address) =>
      _guard(() => _remoteDataSource.addAddress(AddressModel.fromEntity(address)));

  @override
  Future<Either<Failure, List<Address>>> updateAddress(Address address) =>
      _guard(() => _remoteDataSource.updateAddress(AddressModel.fromEntity(address)));

  @override
  Future<Either<Failure, List<Address>>> deleteAddress(String id) =>
      _guard(() => _remoteDataSource.deleteAddress(id));

  @override
  Future<Either<Failure, List<Address>>> setDefaultAddress(String id) =>
      _guard(() => _remoteDataSource.setDefaultAddress(id));
}
