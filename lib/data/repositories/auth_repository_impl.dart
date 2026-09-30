import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../../core/constants/supabase_config.dart';
import '../../core/utils/result.dart';
import '../../data/local/local_storage.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Auth repository implementation.
///
/// Uses mock mode when [SupabaseConfig.isConfigured] is false.
/// Swap mock calls for real Supabase calls when credentials are set.
class AuthRepositoryImpl implements IAuthRepository {
  final LocalStorage _local;

  AuthRepositoryImpl(this._local);

  @override
  bool get isLoggedIn => _local.isLoggedIn;

  @override
  String? get currentEmail => _local.email;

  @override
  String? get currentUserId => _local.userId;

  @override
  Future<Result<String>> signIn({
    required String email,
    required String password,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      return _mockAuth(email: email);
    }
    return Result.guard(() async {
      final res = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      final userId = res.user!.id;
      await _local.saveSession(userId: userId, email: email);
      return userId;
    });
  }

  @override
  Future<Result<String>> signUp({
    required String email,
    required String password,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      return _mockAuth(email: email);
    }
    return Result.guard(() async {
      final res = await Supabase.instance.client.auth
          .signUp(email: email, password: password);
      final userId = res.user!.id;
      await _local.saveSession(userId: userId, email: email);
      return userId;
    });
  }

  @override
  Future<void> signOut() async {
    await _local.clearSession();
    if (SupabaseConfig.isConfigured) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return Result.guard(() async {
      final userId = currentUserId;
      if (SupabaseConfig.isConfigured && userId != null && !userId.startsWith('mock-')) {
        try {
          await Supabase.instance.client.from('profiles').delete().eq('id', userId);
        } catch (_) {}
        try {
          await Supabase.instance.client.from('workout_logs').delete().eq('user_id', userId);
        } catch (_) {}
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (_) {}
      }
      await _local.clearAll();
    });
  }

  Future<Result<String>> _mockAuth({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final userId = 'mock-${email.hashCode.abs()}';
    await _local.saveSession(userId: userId, email: email);
    return Success(userId);
  }
}
