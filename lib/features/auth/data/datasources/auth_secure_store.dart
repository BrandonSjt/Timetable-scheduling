import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/account_user_model.dart';
import '../models/auth_session_model.dart';

abstract interface class AuthSessionStore {
  Future<String?> readRefreshToken();
  Future<String?> readPendingRevocation();
  Future<AccountUserModel?> readUser();
  Future<void> saveSession(AuthSessionModel session);
  Future<void> saveUser(AccountUserModel user);
  Future<void> savePendingRevocation(String token);
  Future<void> clearPendingRevocation();
  Future<void> clearSession();
}

class AuthSecureStore implements AuthSessionStore {
  AuthSecureStore({FlutterSecureStorage? storage})
    : _storage =
          storage ?? const FlutterSecureStorage(aOptions: AndroidOptions());

  static const _refreshKey = 'auth.refresh_token';
  static const _userKey = 'auth.user';
  static const _pendingRevokeKey = 'auth.pending_revoke';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<String?> readPendingRevocation() =>
      _storage.read(key: _pendingRevokeKey);

  @override
  Future<AccountUserModel?> readUser() async {
    final value = await _storage.read(key: _userKey);
    if (value == null) return null;
    try {
      return AccountUserModel.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } on FormatException {
      await _storage.delete(key: _userKey);
      return null;
    }
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    await Future.wait([
      _storage.write(key: _refreshKey, value: session.refreshToken),
      saveUser(session.user as AccountUserModel),
    ]);
  }

  @override
  Future<void> saveUser(AccountUserModel user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  @override
  Future<void> savePendingRevocation(String token) =>
      _storage.write(key: _pendingRevokeKey, value: token);

  @override
  Future<void> clearPendingRevocation() =>
      _storage.delete(key: _pendingRevokeKey);

  @override
  Future<void> clearSession() => Future.wait([
    _storage.delete(key: _refreshKey),
    _storage.delete(key: _userKey),
  ]);
}
