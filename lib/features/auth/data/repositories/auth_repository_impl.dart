import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, void>> sendOtp({required String phone}) async {
    if (!await _networkInfo.isConnected) {
      return const Left<Failure, void>(NetworkFailure());
    }
    try {
      await _remoteDataSource.sendOtp(phone);
      return const Right<Failure, void>(null);
    } on AuthException catch (e) {
      return Left<Failure, void>(AuthFailure(e.message));
    } on UnexpectedException catch (e) {
      return Left<Failure, void>(UnexpectedFailure(e.message));
    } catch (_) {
      return const Left<Failure, void>(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left<Failure, AppUser>(NetworkFailure());
    }
    try {
      final AppUser user = await _remoteDataSource.verifyOtp(phone, otp);
      return Right<Failure, AppUser>(user);
    } on AuthException catch (e) {
      return Left<Failure, AppUser>(AuthFailure(e.message));
    } catch (_) {
      return const Left<Failure, AppUser>(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right<Failure, void>(null);
    } on AuthException catch (e) {
      return Left<Failure, void>(AuthFailure(e.message));
    } catch (_) {
      return const Left<Failure, void>(UnexpectedFailure());
    }
  }

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _remoteDataSource.authStateChanges;
}
