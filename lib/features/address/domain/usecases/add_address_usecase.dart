import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class AddAddressUseCase {
  const AddAddressUseCase(this._repository);

  final AddressRepository _repository;

  Future<Either<Failure, List<Address>>> call(Address address) =>
      _repository.addAddress(address);
}
