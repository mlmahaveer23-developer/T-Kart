import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.sortOrder,
  });

  final String id;
  final String name;

  /// Backend-agnostic icon reference (e.g. `"staples"`) — mapped to a
  /// Flutter `IconData` in the presentation layer only, so this entity
  /// stays free of Flutter imports.
  final String iconKey;
  final int sortOrder;

  @override
  List<Object?> get props => <Object?>[id, name, iconKey, sortOrder];
}
