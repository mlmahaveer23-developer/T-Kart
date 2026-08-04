import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cart_item_model.dart';

const String _prefsKeyCart = 'tc_cart_items';

/// Cart is stored locally (device-scoped, not synced to Supabase) — it's
/// draft/pre-checkout state, not a durable record, so local persistence
/// is the right tradeoff for this phase. Checkout (Phase 5) is where an
/// order actually gets written server-side.
abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getItems();
  Future<void> saveItems(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  @override
  Future<List<CartItemModel>> getItems() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_prefsKeyCart);
      if (raw == null || raw.isEmpty) return <CartItemModel>[];
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((dynamic e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Could not read your cart.');
    }
  }

  @override
  Future<void> saveItems(List<CartItemModel> items) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(items.map((CartItemModel e) => e.toJson()).toList());
      await prefs.setString(_prefsKeyCart, encoded);
    } catch (_) {
      throw const CacheException('Could not save your cart.');
    }
  }
}
