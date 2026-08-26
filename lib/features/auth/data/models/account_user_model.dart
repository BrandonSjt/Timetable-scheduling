import '../../domain/entities/account_user.dart';

class AccountUserModel extends AccountUser {
  const AccountUserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.language,
    required super.accessibilityEnabled,
    required super.notificationsEnabled,
    super.name,
    super.phone,
  });

  factory AccountUserModel.fromJson(Map<String, dynamic> json) =>
      AccountUserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        language: json['language'] as String? ?? 'id',
        accessibilityEnabled: json['accessibilityEnabled'] as bool? ?? false,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'language': language,
    'accessibilityEnabled': accessibilityEnabled,
    'notificationsEnabled': notificationsEnabled,
    'name': name,
    'phone': phone,
  };
}
