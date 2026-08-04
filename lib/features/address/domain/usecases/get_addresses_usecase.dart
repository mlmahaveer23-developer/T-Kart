import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase {
  const GetAddressesUseCase(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, List<Address>>> call() => _repository.getAddresses();
}
