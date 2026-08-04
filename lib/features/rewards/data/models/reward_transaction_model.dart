import '../../domain/entities/reward_transaction.dart';

class RewardTransactionModel extends RewardTransaction {
  const RewardTransactionModel({
    required super.id,
    required super.type,
    required super.amountRupees,
    required super.description,
    required super.createdAt,
    super.orderId,
  });

  factory RewardTransactionModel.fromJson(Map<String, dynamic> json) {
    return RewardTransactionModel(
      id: json['id'] as String,
      type: RewardTransactionType.fromString(json['type'] as String),
      amountRupees: json['amount_rupees'] as int,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      orderId: json['order_id'] as String?,
    );
  }
}
