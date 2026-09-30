import '../../repositories/i_auth_repository.dart';
import '../../../core/utils/result.dart';

/// Permanently deletes the user account and cleans up all data.
class DeleteAccountUseCase {
  final IAuthRepository _repository;

  const DeleteAccountUseCase(this._repository);

  Future<Result<void>> execute() {
    return _repository.deleteAccount();
  }

  Future<Result<void>> call() => execute();
}
