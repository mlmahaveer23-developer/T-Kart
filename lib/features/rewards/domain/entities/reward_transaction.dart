import 'package:equatable/equatable.dart';

enum RewardTransactionType {
  earned,
  redeemed;

  static RewardTransactionType fromString(String value) {
    return RewardTransactionType.values.firstWhere(
      (RewardTransactionType t) => t.name == value,
      orElse: () => RewardTransactionType.earned,
    );
  }
}

/// A single ledger entry. The wallet balance shown on screen is always
/// derived by summing these (earned minus redeemed) rather than stored
/// as a separate number — see the migration file for why.
class RewardTransaction extends Equatable {
  const RewardTransaction({
    required this.id,
    required this.type,
    required this.amountRupees,
    required this.description,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final RewardTransactionType type;
  final int amountRupees;
  final String description;
  final DateTime createdAt;
  final String? orderId;

  /// Signed amount — positive for earned, negative for redeemed —
  /// convenient for summing a balance directly.
  int get signedAmountRupees =>
      type == RewardTransactionType.earned ? amountRupees : -amountRupees;

  @override
  List<Object?> get props =>
      <Object?>[id, type, amountRupees, description, createdAt, orderId];
}
