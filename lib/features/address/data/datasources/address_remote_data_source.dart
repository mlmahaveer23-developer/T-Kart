import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<List<AddressModel>> addAddress(AddressModel address);
  Future<List<AddressModel>> updateAddress(AddressModel address);
  Future<List<AddressModel>> deleteAddress(String id);
  Future<List<AddressModel>> setDefaultAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  AddressRemoteDataSourceImpl(this._client);

  final supabase.SupabaseClient _client;

  String get _userId {
    final String? id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    return id;
  }

  Future<T> _guard<T>(Future<T> Function() action, String fallbackMessage) async {
    try {
      return await action();
    } on AuthException {
      rethrow;
    } catch (_) {
      throw ServerException(fallbackMessage);
    }
  }

  Future<List<AddressModel>> _fetchAll() async {
    final List<Map<String, dynamic>> rows = await _client
        .from('addresses')
        .select()
        .eq('user_id', _userId)
        .order('is_default', ascending: false)
        .order('created_at');
    return rows.map(AddressModel.fromJson).toList();
  }

  /// A user has at most one default address — clear any existing
  /// default before a new one is set.
  Future<void> _clearExistingDefault() async {
    await _client
        .from('addresses')
        .update(<String, dynamic>{'is_default': false})
        .eq('user_id', _userId)
        .eq('is_default', true);
  }

  @override
  Future<List<AddressModel>> getAddresses() =>
      _guard(_fetchAll, 'Could not load your addresses.');

  @override
  Future<List<AddressModel>> addAddress(AddressModel address) {
    return _guard(() async {
      if (address.isDefault) await _clearExistingDefault();
      await _client.from('addresses').insert(address.toInsertJson(_userId));
      return _fetchAll();
    }, 'Could not save this address.');
  }

  @override
  Future<List<AddressModel>> updateAddress(AddressModel address) {
    return _guard(() async {
      if (address.isDefault) await _clearExistingDefault();
      await _client
          .from('addresses')
          .update(address.toUpdateJson())
          .eq('id', address.id);
      return _fetchAll();
    }, 'Could not update this address.');
  }

  @override
  Future<List<AddressModel>> deleteAddress(String id) {
    return _guard(() async {
      await _client.from('addresses').delete().eq('id', id);
      return _fetchAll();
    }, 'Could not delete this address.');
  }

  @override
  Future<List<AddressModel>> setDefaultAddress(String id) {
    return _guard(() async {
      await _clearExistingDefault();
      await _client
          .from('addresses')
          .update(<String, dynamic>{'is_default': true})
          .eq('id', id);
      return _fetchAll();
    }, 'Could not update your default address.');
  }
}
