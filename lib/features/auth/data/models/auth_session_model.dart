import '../../domain/entities/auth_session.dart';
import 'account_user_model.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required AccountUserModel super.user,
    required super.accessToken,
    required super.refreshToken,
    required super.accessTokenExpiresIn,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        user: AccountUserModel.fromJson(json['user'] as Map<String, dynamic>),
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        accessTokenExpiresIn: json['accessTokenExpiresIn'] as int? ?? 900,
      );
}
