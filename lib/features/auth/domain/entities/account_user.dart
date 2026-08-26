class AccountUser {
  const AccountUser({
    required this.id,
    required this.email,
    required this.role,
    required this.language,
    required this.accessibilityEnabled,
    required this.notificationsEnabled,
    this.name,
    this.phone,
  });

  final String id;
  final String email;
  final String role;
  final String language;
  final bool accessibilityEnabled;
  final bool notificationsEnabled;
  final String? name;
  final String? phone;
}
