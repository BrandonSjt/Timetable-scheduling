import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:timetable/features/auth/data/datasources/auth_secure_store.dart';
import 'package:timetable/features/auth/data/models/account_user_model.dart';
import 'package:timetable/features/auth/data/models/auth_session_model.dart';
import 'package:timetable/features/auth/data/repositories/auth_repository_impl.dart';

const _user = AccountUserModel(
  id: 'user-1',
  email: 'user@example.com',
  name: 'Riyadh',
  role: 'REGISTERED',
  language: 'id',
  accessibilityEnabled: false,
  notificationsEnabled: true,
);

AuthSessionModel _session({
  String access = 'access-1',
  String refresh = 'refresh-1',
}) => AuthSessionModel(
  user: _user,
  accessToken: access,
  refreshToken: refresh,
  accessTokenExpiresIn: 900,
);

class _MemoryStore implements AuthSessionStore {
  String? refreshToken;
  String? pendingRevocation;
  AccountUserModel? user;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<String?> readPendingRevocation() async => pendingRevocation;

  @override
  Future<AccountUserModel?> readUser() async => user;

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    refreshToken = session.refreshToken;
    user = session.user as AccountUserModel;
  }

  @override
  Future<void> saveUser(AccountUserModel next) async => user = next;

  @override
  Future<void> savePendingRevocation(String token) async =>
      pendingRevocation = token;

  @override
  Future<void> clearPendingRevocation() async => pendingRevocation = null;

  @override
  Future<void> clearSession() async {
    refreshToken = null;
    user = null;
  }
}

class _FakeRemote extends AuthRemoteDataSource {
  _FakeRemote() : super();

  int refreshCalls = 0;
  int logoutCalls = 0;
  int profileCalls = 0;
  bool failRefresh = false;
  bool failLogout = false;
  bool unauthorizedFirstProfile = false;
  Duration refreshDelay = Duration.zero;
  final List<String> refreshTokensSeen = [];
  final List<String> accessTokensSeen = [];

  @override
  Future<AuthSessionModel> refresh(String refreshToken) async {
    refreshCalls += 1;
    refreshTokensSeen.add(refreshToken);
    if (refreshDelay > Duration.zero) {
      await Future<void>.delayed(refreshDelay);
    }
    if (failRefresh) {
      throw const AuthRemoteException(
        'INVALID_REFRESH_TOKEN',
        'expired',
      );
    }
    return _session(
      access: 'access-$refreshCalls',
      refresh: 'refresh-${refreshCalls + 1}',
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalls += 1;
    if (failLogout) {
      throw const AuthRemoteException('NETWORK_ERROR', 'offline', isNetwork: true);
    }
  }

  @override
  Future<AccountUserModel> updateProfile(
    String accessToken,
    Map<String, dynamic> changes,
  ) async {
    profileCalls += 1;
    accessTokensSeen.add(accessToken);
    if (unauthorizedFirstProfile && profileCalls == 1) {
      throw const AuthRemoteException('UNAUTHORIZED', 'expired access');
    }
    return _user;
  }
}

void main() {
  test('refresh is deduplicated across concurrent authorized requests', () async {
    final store = _MemoryStore()..refreshToken = 'refresh-1';
    final remote = _FakeRemote()
      ..refreshDelay = const Duration(milliseconds: 40);
    final repository = AuthRepositoryImpl(remote: remote, store: store);

    final results = await Future.wait([
      repository.updateProfile(name: 'A'),
      repository.updateProfile(name: 'B'),
    ]);

    expect(results, everyElement(_user));
    expect(remote.refreshCalls, 1);
    expect(remote.profileCalls, 2);
    expect(store.refreshToken, 'refresh-2');
  });

  test('expired refresh clears local session for guest fallback', () async {
    final store = _MemoryStore()
      ..refreshToken = 'stale-refresh'
      ..user = _user;
    final remote = _FakeRemote()..failRefresh = true;
    final repository = AuthRepositoryImpl(remote: remote, store: store);

    final bootstrap = await repository.bootstrap();

    expect(bootstrap.user, isNull);
    expect(bootstrap.offline, isFalse);
    expect(store.refreshToken, isNull);
    expect(store.user, isNull);
    expect(repository.currentUser, isNull);
  });

  test('logout revokes server token and clears secure storage', () async {
    final store = _MemoryStore()
      ..refreshToken = 'refresh-1'
      ..user = _user;
    final remote = _FakeRemote();
    final repository = AuthRepositoryImpl(remote: remote, store: store);
    await repository.bootstrap();

    await repository.logout();

    expect(remote.logoutCalls, 1);
    expect(store.refreshToken, isNull);
    expect(store.user, isNull);
    expect(repository.currentUser, isNull);
  });

  test('logout keeps pending revocation when server revoke fails', () async {
    final store = _MemoryStore()
      ..refreshToken = 'refresh-1'
      ..user = _user;
    final remote = _FakeRemote()..failLogout = true;
    final repository = AuthRepositoryImpl(remote: remote, store: store);

    await repository.logout();

    expect(store.refreshToken, isNull);
    expect(store.pendingRevocation, 'refresh-1');
  });

  test('authorized request retries once after access token 401', () async {
    final store = _MemoryStore()..refreshToken = 'refresh-1';
    final remote = _FakeRemote()..unauthorizedFirstProfile = true;
    final repository = AuthRepositoryImpl(remote: remote, store: store);

    final user = await repository.updateProfile(name: 'Riyadh');

    expect(user, _user);
    // Initial authorized call needs a refresh, then one more after 401.
    expect(remote.refreshCalls, 2);
    expect(remote.profileCalls, 2);
    expect(remote.accessTokensSeen.last, 'access-2');
  });
}
