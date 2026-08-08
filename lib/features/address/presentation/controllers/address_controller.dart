import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/address.dart';
import '../providers/address_providers.dart';

class AddressController extends AsyncNotifier<List<Address>> {
  @override
  FutureOr<List<Address>> build() async {
    final result = await ref.read(getAddressesUseCaseProvider).call();
    return result.fold((failure) => throw failure, (addresses) => addresses);
  }

  /// Returns true on success.
  Future<bool> addAddress(Address address) =>
      _mutate(() => ref.read(addAddressUseCaseProvider).call(address));

  Future<bool> updateAddress(Address address) =>
      _mutate(() => ref.read(updateAddressUseCaseProvider).call(address));

  Future<bool> deleteAddress(String id) =>
      _mutate(() => ref.read(deleteAddressUseCaseProvider).call(id));

  Future<bool> setDefault(String id) =>
      _mutate(() => ref.read(setDefaultAddressUseCaseProvider).call(id));

  Future<bool> _mutate(Future<dynamic> Function() action) async {
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncError<List<Address>>(failure, StackTrace.current);
        return false;
      },
      (List<Address> addresses) {
        state = AsyncData<List<Address>>(addresses);
        return true;
      },
    );
  }
}

final AsyncNotifierProvider<AddressController, List<Address>>
    addressControllerProvider =
    AsyncNotifierProvider<AddressController, List<Address>>(AddressController.new);

/// Convenience accessor for checkout — the current default address, if any.
final Provider<Address?> defaultAddressProvider = Provider<Address?>((Ref ref) {
  final List<Address> addresses =
      ref.watch(addressControllerProvider).valueOrNull ?? const <Address>[];
  if (addresses.isEmpty) return null;
  return addresses.firstWhere(
    (Address a) => a.isDefault,
    orElse: () => addresses.first,
  );
});
