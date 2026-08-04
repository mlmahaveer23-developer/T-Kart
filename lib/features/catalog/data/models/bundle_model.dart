import '../../domain/entities/bundle.dart';

/// Maps Supabase's `bundles` row shape (snake_case columns) to the
/// domain entity. Kept explicit rather than code-generated so the
/// mapping is easy to audit against the migration in
/// `supabase/migrations/0001_catalog_schema.sql`.
class BundleModel extends Bundle {
  const BundleModel({
    required super.id,
    required super.name,
    required super.description,
    required super.priceRupees,
    required super.rewardValueRupees,
    required super.isFeatured,
    super.categoryId,
    super.imageUrl,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    return BundleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      priceRupees: json['price_rupees'] as int,
      rewardValueRupees: (json['reward_value_rupees'] as int?) ?? 0,
      isFeatured: (json['is_featured'] as bool?) ?? false,
      categoryId: json['category_id'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
