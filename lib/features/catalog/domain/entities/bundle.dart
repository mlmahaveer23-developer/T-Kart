import 'package:equatable/equatable.dart';

class Bundle extends Equatable {
  const Bundle({
    required this.id,
    required this.name,
    required this.description,
    required this.priceRupees,
    required this.rewardValueRupees,
    required this.isFeatured,
    this.categoryId,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final int priceRupees;
  final int rewardValueRupees;
  final bool isFeatured;
  final String? categoryId;
  final String? imageUrl;

  bool get hasReward => rewardValueRupees > 0;

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        description,
        priceRupees,
        rewardValueRupees,
        isFeatured,
        categoryId,
        imageUrl,
      ];
}
