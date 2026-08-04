import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reward_transaction.dart';
import '../repositories/rewards_repository.dart';

class GetTransactionsUseCase {
  const GetTransactionsUseCase(this._repository);

  final RewardsRepository _repository;

  Future<Either<Failure, List<RewardTransaction>>> call() =>
      _repository.getTransactions();
}
