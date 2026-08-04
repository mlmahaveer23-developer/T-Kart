import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exposes the singleton Supabase client to the rest of the app.
/// `Supabase.initialize` is called once in `main.dart` before `runApp`;
/// this provider just hands out a reference so features never import
/// `supabase_flutter` directly outside the data layer.
final Provider<SupabaseClient> supabaseClientProvider =
    Provider<SupabaseClient>((Ref ref) => Supabase.instance.client);

/// Streams auth state so any part of the app (router redirect logic,
/// auth-gated widgets) can react to sign-in/sign-out without polling.
final StreamProvider<AuthState> authStateChangesProvider =
    StreamProvider<AuthState>((Ref ref) {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
