import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/address_remote_data_source.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/set_default_address_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';

final Provider<AddressRemoteDataSource> addressRemoteDataSourceProvider =
    Provider<AddressRemoteDataSource>(
  (Ref ref) => AddressRemoteDataSourceImpl(ref.watch(supabaseClientProvider)),
);

final Provider<AddressRepository> addressRepositoryProvider =
    Provider<AddressRepository>(
  (Ref ref) => AddressRepositoryImpl(
    remoteDataSource: ref.watch(addressRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final Provider<GetAddressesUseCase> getAddressesUseCaseProvider =
    Provider<GetAddressesUseCase>(
  (Ref ref) => GetAddressesUseCase(ref.watch(addressRepositoryProvider)),
);

final Provider<AddAddressUseCase> addAddressUseCaseProvider =
    Provider<AddAddressUseCase>(
  (Ref ref) => AddAddressUseCase(ref.watch(addressRepositoryProvider)),
);

final Provider<UpdateAddressUseCase> updateAddressUseCaseProvider =
    Provider<UpdateAddressUseCase>(
  (Ref ref) => UpdateAddressUseCase(ref.watch(addressRepositoryProvider)),
);

final Provider<DeleteAddressUseCase> deleteAddressUseCaseProvider =
    Provider<DeleteAddressUseCase>(
  (Ref ref) => DeleteAddressUseCase(ref.watch(addressRepositoryProvider)),
);

final Provider<SetDefaultAddressUseCase> setDefaultAddressUseCaseProvider =
    Provider<SetDefaultAddressUseCase>(
  (Ref ref) => SetDefaultAddressUseCase(ref.watch(addressRepositoryProvider)),
);
