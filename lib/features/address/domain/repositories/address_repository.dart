import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/address.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<Address>>> getAddresses();

  /// Creates a new address. If [address.isDefault] is true, any
  /// previously-default address is un-set (a user has at most one
  /// default at a time).
  Future<Either<Failure, List<Address>>> addAddress(Address address);

  Future<Either<Failure, List<Address>>> updateAddress(Address address);

  Future<Either<Failure, List<Address>>> deleteAddress(String id);

  Future<Either<Failure, List<Address>>> setDefaultAddress(String id);
}
