import 'account_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresIn,
  });

  final AccountUser user;
  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresIn;
}

class AuthBootstrapResult {
  const AuthBootstrapResult({this.user, this.offline = false});

  final AccountUser? user;
  final bool offline;
  bool get isAuthenticated => user != null;
}
