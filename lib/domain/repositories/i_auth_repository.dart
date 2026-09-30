import '../../core/utils/result.dart';

/// Abstract auth repository interface.
///
/// Implementation lives in data/repositories/auth_repository_impl.dart
abstract interface class IAuthRepository {
  /// Returns true if a session currently exists.
  bool get isLoggedIn;

  /// Current user's email, or null.
  String? get currentEmail;

  /// Current user's ID, or null.
  String? get currentUserId;

  /// Signs in with email and password.
  Future<Result<String>> signIn({
    required String email,
    required String password,
  });

  /// Creates a new account.
  Future<Result<String>> signUp({
    required String email,
    required String password,
  });

  /// Signs out and clears session.
  Future<void> signOut();

  /// Permanently deletes the account and all associated user data.
  Future<Result<void>> deleteAccount();
}
