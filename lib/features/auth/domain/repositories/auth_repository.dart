import '../entities/account_user.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  AccountUser? get currentUser;

  Future<AuthBootstrapResult> bootstrap();
  Future<AccountUser> login({required String email, required String password});
  Future<AccountUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<void> logout();
  Future<AccountUser> updateProfile({
    String? name,
    String? phone,
    String? language,
    bool? accessibilityEnabled,
    bool? notificationsEnabled,
  });
}
