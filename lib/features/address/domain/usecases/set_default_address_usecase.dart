import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class SetDefaultAddressUseCase {
  const SetDefaultAddressUseCase(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, List<Address>>> call(String id) =>
      _repository.setDefaultAddress(id);
}
