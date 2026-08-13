import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../models/account_user_model.dart';
import '../models/auth_session_model.dart';

class AuthRemoteException implements Exception {
  const AuthRemoteException(this.code, this.message, {this.isNetwork = false});

  final String code;
  final String message;
  final bool isNetwork;
  bool get isUnauthorized =>
      code == 'INVALID_REFRESH_TOKEN' ||
      code == 'INVALID_TOKEN' ||
      code == 'USER_REQUIRED' ||
      code == 'UNAUTHORIZED';
}

class AuthRemoteDataSource {
  AuthRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 10);

  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => _sessionRequest('/auth/register', {
    'name': name,
    'email': email,
    'password': password,
    if (phone?.isNotEmpty == true) 'phone': phone,
    'deviceName': 'KAI Access Android',
  });

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) => _sessionRequest('/auth/login', {
    'email': email,
    'password': password,
    'deviceName': 'KAI Access Android',
  });

  Future<AuthSessionModel> refresh(String refreshToken) =>
      _sessionRequest('/auth/refresh', {'refreshToken': refreshToken});

  Future<void> logout(String refreshToken) async {
    await _request(
      'POST',
      '/auth/logout',
      body: {'refreshToken': refreshToken},
    );
  }

  Future<AccountUserModel> getProfile(String accessToken) async =>
      AccountUserModel.fromJson(
        await _request('GET', '/profile', accessToken: accessToken),
      );

  Future<AccountUserModel> updateProfile(
    String accessToken,
    Map<String, dynamic> changes,
  ) async => AccountUserModel.fromJson(
    await _request(
      'PATCH',
      '/profile',
      accessToken: accessToken,
      body: changes,
    ),
  );

  Future<AuthSessionModel> _sessionRequest(
    String path,
    Map<String, dynamic> body,
  ) async =>
      AuthSessionModel.fromJson(await _request('POST', path, body: body));

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    String? accessToken,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };
      final response = switch (method) {
        'GET' => await _client.get(uri, headers: headers).timeout(_timeout),
        'PATCH' =>
          await _client
              .patch(uri, headers: headers, body: jsonEncode(body))
              .timeout(_timeout),
        _ =>
          await _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(_timeout),
      };
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        final error = decoded['error'] as Map<String, dynamic>?;
        throw AuthRemoteException(
          error?['code'] as String? ?? 'REQUEST_FAILED',
          error?['message'] as String? ?? 'Request failed',
        );
      }
      return (decoded['data'] as Map<String, dynamic>?) ?? const {};
    } on AuthRemoteException {
      rethrow;
    } on TimeoutException catch (_) {
      throw const AuthRemoteException(
        'NETWORK_ERROR',
        'Connection timed out',
        isNetwork: true,
      );
    } on SocketException catch (_) {
      throw const AuthRemoteException(
        'NETWORK_ERROR',
        'No network connection',
        isNetwork: true,
      );
    } on http.ClientException catch (_) {
      throw const AuthRemoteException(
        'NETWORK_ERROR',
        'Cannot reach server',
        isNetwork: true,
      );
    } on FormatException catch (_) {
      throw const AuthRemoteException(
        'INVALID_RESPONSE',
        'Invalid server response',
      );
    }
  }
}
