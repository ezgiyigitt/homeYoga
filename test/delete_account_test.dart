import 'package:flutter_test/flutter_test.dart';
import 'package:homeyoga/core/utils/result.dart';
import 'package:homeyoga/domain/repositories/i_auth_repository.dart';
import 'package:homeyoga/domain/usecases/auth/delete_account_usecase.dart';

class MockAuthRepository implements IAuthRepository {
  bool deleteCalled = false;

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalled = true;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('DeleteAccountUseCase calls repository.deleteAccount successfully', () async {
    final mockRepo = MockAuthRepository();
    final useCase = DeleteAccountUseCase(mockRepo);

    final result = await useCase();

    expect(mockRepo.deleteCalled, isTrue);
    expect(result.isSuccess, isTrue);
  });
}
