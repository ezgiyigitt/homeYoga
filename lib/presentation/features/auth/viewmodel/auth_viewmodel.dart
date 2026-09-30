import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/app_providers.dart';

// ── Auth State ───────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ── Auth ViewModel ───────────────────────────────────────────────
class AuthViewModel extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthViewModel(this._ref) : super(const AuthState());

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthState(isLoading: true);
    final result = await _ref
        .read(signInUseCaseProvider)
        .execute(email: email, password: password);
    
    final success = await result.when(
      onSuccess: (userId) async {
        final profileResult = await _ref.read(profileRepositoryProvider).getProfile(userId);
        if (profileResult.isSuccess && profileResult.dataOrNull != null) {
          final profile = profileResult.dataOrNull!;
          await _ref.read(localStorageProvider).saveOnboardingComplete(
            firstName: profile.firstName,
            lastName: profile.lastName,
          );
        }
        state = const AuthState();
        return true;
      },
      onFailure: (msg) async {
        state = AuthState(error: _friendly(msg));
        return false;
      },
    );
    return success;
  }

  Future<bool> signUp({required String email, required String password}) async {
    state = const AuthState(isLoading: true);
    final result = await _ref
        .read(signUpUseCaseProvider)
        .execute(email: email, password: password);
    return result.when(
      onSuccess: (_) {
        state = const AuthState();
        return true;
      },
      onFailure: (msg) {
        state = AuthState(error: _friendly(msg));
        return false;
      },
    );
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
  }

  void clearError() => state = state.copyWith(error: null);

  String _friendly(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('already registered')) {
      return 'This email is already in use.';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'No internet connection.';
    }
    return raw; // Return raw error for debugging
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(ref),
);
