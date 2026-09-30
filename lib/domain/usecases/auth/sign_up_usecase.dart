import '../../repositories/i_auth_repository.dart';
import '../../../core/utils/result.dart';

/// Creates a new account with email and password.
class SignUpUseCase {
  final IAuthRepository _repository;

  const SignUpUseCase(this._repository);

  /// Returns the new user ID on success, or a friendly error message.
  Future<Result<String>> execute({
    required String email,
    required String password,
  }) {
    return _repository.signUp(email: email, password: password);
  }
}
