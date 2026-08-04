import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_info.dart';

final Provider<Connectivity> connectivityProvider =
    Provider<Connectivity>((Ref ref) => Connectivity());

final Provider<NetworkInfo> networkInfoProvider = Provider<NetworkInfo>(
  (Ref ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

/// Live connectivity stream — used to drive a global "you're offline"
/// banner without every screen re-implementing the check.
final StreamProvider<bool> isConnectedProvider = StreamProvider<bool>((Ref ref) {
  final NetworkInfo info = ref.watch(networkInfoProvider);
  return info.onConnectivityChanged;
});
