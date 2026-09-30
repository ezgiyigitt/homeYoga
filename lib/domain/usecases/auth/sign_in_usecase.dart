import '../../repositories/i_auth_repository.dart';
import '../../../core/utils/result.dart';

/// Signs a user in with email and password.
class SignInUseCase {
  final IAuthRepository _repository;

  const SignInUseCase(this._repository);

  /// Returns the user ID on success, or a friendly error message.
  Future<Result<String>> execute({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
