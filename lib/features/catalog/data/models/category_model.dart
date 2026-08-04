import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconKey,
    required super.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: (json['icon_key'] as String?) ?? 'category',
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }
}
