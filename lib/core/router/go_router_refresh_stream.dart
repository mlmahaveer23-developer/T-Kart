import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapts any [Stream] into a [Listenable] so [GoRouter]'s
/// `refreshListenable` can re-run `redirect:` whenever the stream emits
/// — used here to react to Supabase auth state changes (sign-in,
/// sign-out, token refresh triggered elsewhere) without polling.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
