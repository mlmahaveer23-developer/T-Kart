import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/place_order_input.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> placeOrder(PlaceOrderInput input);
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._client);

  final supabase.SupabaseClient _client;

  String get _userId {
    final String? id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AuthException('You need to be signed in to place an order.');
    }
    return id;
  }

  Future<T> _guard<T>(Future<T> Function() action, String fallbackMessage) async {
    try {
      return await action();
    } on AuthException {
      rethrow;
    } on supabase.PostgrestException catch (e) {
      // place_order() raises exceptions with specific, user-readable
      // messages (invalid coupon, empty cart, etc) — surface those
      // instead of flattening everything to the generic fallback.
      throw ServerException(e.message);
    } catch (_) {
      throw ServerException(fallbackMessage);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchItemRows(String orderId) async {
    return _client.from('order_items').select().eq('order_id', orderId);
  }

  @override
  Future<OrderModel> placeOrder(PlaceOrderInput input) {
    return _guard(() async {
      // A single RPC call — Postgres runs the whole function body as
      // one transaction, so the order row and its line items either
      // both commit or neither does. See
      // supabase/migrations/0004_atomic_order_placement.sql.
      final String orderId = await _client.rpc<String>(
        'place_order',
        params: <String, dynamic>{
          'p_items': input.items
              .map((item) => OrderItemModel(
                    bundleId: item.bundleId,
                    bundleName: item.bundleName,
                    priceRupees: item.priceRupees,
                    rewardValueRupees: item.rewardValueRupees,
                    quantity: item.quantity,
                  ).toRpcJson())
              .toList(),
          'p_recipient_name': input.recipientName,
          'p_phone': input.phone,
          'p_address_line1': input.addressLine1,
          'p_address_line2': input.addressLine2,
          'p_city': input.city,
          'p_state': input.state,
          'p_pincode': input.pincode,
          'p_coupon_code': input.couponCode,
        },
      );

      return getOrderById(orderId);
    }, 'Could not place your order.');
  }

  @override
  Future<List<OrderModel>> getOrders() {
    return _guard(() async {
      final List<Map<String, dynamic>> orderRows = await _client
          .from('orders')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      final List<OrderModel> orders = <OrderModel>[];
      for (final Map<String, dynamic> row in orderRows) {
        final List<Map<String, dynamic>> itemRows =
            await _fetchItemRows(row['id'] as String);
        orders.add(OrderModel.fromJson(row, itemRows: itemRows));
      }
      return orders;
    }, 'Could not load your orders.');
  }

  @override
  Future<OrderModel> getOrderById(String id) {
    return _guard(() async {
      final Map<String, dynamic> row =
          await _client.from('orders').select().eq('id', id).single();
      final List<Map<String, dynamic>> itemRows = await _fetchItemRows(id);
      return OrderModel.fromJson(row, itemRows: itemRows);
    }, 'Could not load this order.');
  }
}
