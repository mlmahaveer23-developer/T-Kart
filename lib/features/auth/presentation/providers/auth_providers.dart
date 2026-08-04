import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>(
  (Ref ref) => AuthRemoteDataSourceImpl(ref.watch(supabaseClientProvider)),
);

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final Provider<SendOtpUseCase> sendOtpUseCaseProvider = Provider<SendOtpUseCase>(
  (Ref ref) => SendOtpUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<VerifyOtpUseCase> verifyOtpUseCaseProvider =
    Provider<VerifyOtpUseCase>(
  (Ref ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<SignOutUseCase> signOutUseCaseProvider = Provider<SignOutUseCase>(
  (Ref ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

/// Domain-mapped auth state stream — the router and app shell watch this
/// instead of touching Supabase types directly.
final StreamProvider<AppUser?> appAuthStateProvider = StreamProvider<AppUser?>(
  (Ref ref) => ref.watch(authRepositoryProvider).authStateChanges,
);
