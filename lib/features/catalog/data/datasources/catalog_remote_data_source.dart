import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../models/bundle_model.dart';
import '../models/category_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<BundleModel>> getFeaturedBundles();
  Future<List<BundleModel>> getBundles({String? categoryId});
  Future<List<BundleModel>> searchBundles(String query);
  Future<BundleModel> getBundleById(String id);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(this._client);

  final supabase.SupabaseClient _client;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from('categories')
          .select()
          .order('sort_order');
      return rows.map(CategoryModel.fromJson).toList();
    } catch (_) {
      throw const ServerException('Could not load categories.');
    }
  }

  @override
  Future<List<BundleModel>> getFeaturedBundles() async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from('bundles')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      return rows.map(BundleModel.fromJson).toList();
    } catch (_) {
      throw const ServerException('Could not load featured bundles.');
    }
  }

  @override
  Future<List<BundleModel>> getBundles({String? categoryId}) async {
    try {
      var query = _client.from('bundles').select();
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      final List<Map<String, dynamic>> rows =
          await query.order('created_at', ascending: false);
      return rows.map(BundleModel.fromJson).toList();
    } catch (_) {
      throw const ServerException('Could not load bundles.');
    }
  }

  @override
  Future<List<BundleModel>> searchBundles(String query) async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from('bundles')
          .select()
          .ilike('name', '%$query%')
          .order('name');
      return rows.map(BundleModel.fromJson).toList();
    } catch (_) {
      throw const ServerException('Search failed. Please try again.');
    }
  }

  @override
  Future<BundleModel> getBundleById(String id) async {
    try {
      final Map<String, dynamic> row =
          await _client.from('bundles').select().eq('id', id).single();
      return BundleModel.fromJson(row);
    } catch (_) {
      throw const ServerException('Could not load this bundle.');
    }
  }
}
