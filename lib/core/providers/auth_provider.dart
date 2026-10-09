import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AppAuthState {
  final User? user;
  final Profile? profile;
  final bool isLoading;
  final String? errorMessage;

  const AppAuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => profile?.role == 'admin';

  AppAuthState copyWith({
    User? user,
    Profile? profile,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AppAuthState(
      user: clearUser ? null : (user ?? this.user),
      profile: clearUser ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AppAuthNotifier extends Notifier<AppAuthState> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  AppAuthState build() {
    _init();
    ref.onDispose(() {
      _authSubscription?.cancel();
    });
    return const AppAuthState(isLoading: true);
  }

  void _init() {
    try {
      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        _fetchProfile(currentUser);
      } else {
        state = const AppAuthState(isLoading: false);
      }

      _authSubscription = client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _fetchProfile(session.user);
        } else {
          state = const AppAuthState(isLoading: false);
        }
      });
    } catch (_) {
      state = const AppAuthState(isLoading: false);
    }
  }

  Future<void> _fetchProfile(User user) async {
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      Profile? profile;
      if (res != null) {
        profile = Profile.fromJson(res);
      } else {
        // Fallback profile if trigger is still propagating
        final meta = user.userMetadata ?? {};
        profile = Profile(
          id: user.id,
          email: user.email ?? '',
          fullName: (meta['full_name'] ?? meta['name']) as String?,
          phone: meta['phone'] as String?,
          role: (meta['role'] as String?) ?? 'customer',
          preferredCurrency: 'NGN',
          savedAddresses: const [],
          createdAt: DateTime.now(),
        );
      }

      state = AppAuthState(
        user: user,
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Failed to load profile: $e');
      state = AppAuthState(
        user: user,
        isLoading: false,
      );
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final client = Supabase.instance.client;
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': fullName.trim(),
          'phone': (phone ?? '').trim(),
          'role': 'customer',
        },
      );

      final user = response.user;
      if (user != null) {
        await _fetchProfile(user);
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'Registration could not be completed.');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'An error occurred during account creation: $e');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final client = Supabase.instance.client;
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;
      if (user != null) {
        await _fetchProfile(user);
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'Sign in failed.');
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'An unexpected error occurred: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final client = Supabase.instance.client;
      await client.auth.signOut();
    } catch (_) {}
    state = const AppAuthState(isLoading: false);
  }
}

final authProvider = NotifierProvider<AppAuthNotifier, AppAuthState>(() {
  return AppAuthNotifier();
});
