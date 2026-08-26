import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_scope.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.register = false});

  final bool register;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  late bool _register;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _register = widget.register;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthScope.of(context, listen: false);
    final success = _register
        ? await auth.register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          )
        : await auth.login(email: _email.text.trim(), password: _password.text);
    if (success && mounted) context.go('/akun');
  }

  String _errorMessage(AppLocalizations l10n, String? code) => switch (code) {
    'INVALID_CREDENTIALS' => l10n.authInvalidCredentials,
    'EMAIL_ALREADY_USED' => l10n.authEmailUsed,
    'NETWORK_ERROR' => l10n.authNetworkError,
    _ => l10n.authGenericError,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.train_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _register ? l10n.authRegisterTitle : l10n.authSignInTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _register
                          ? l10n.authRegisterSubtitle
                          : l10n.authSignInSubtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_register) ...[
                      _field(
                        controller: _name,
                        label: l10n.authName,
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (value) => (value?.trim().length ?? 0) < 2
                            ? l10n.authNameRequired
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    _field(
                      controller: _email,
                      label: l10n.authEmail,
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)
                            ? null
                            : l10n.authEmailInvalid;
                      },
                    ),
                    if (_register) ...[
                      const SizedBox(height: 14),
                      _field(
                        controller: _phone,
                        label: l10n.authPhoneOptional,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _field(
                      controller: _password,
                      label: l10n.authPassword,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => auth.isBusy ? null : _submit(),
                      validator: (value) => (value?.length ?? 0) < 8
                          ? l10n.authPasswordMin
                          : null,
                      autofillHints: _register
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? l10n.authShowPassword
                            : l10n.authHidePassword,
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    if (_register) ...[
                      const SizedBox(height: 14),
                      _field(
                        controller: _passwordConfirmation,
                        label: l10n.authPasswordConfirmation,
                        icon: Icons.lock_reset_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => auth.isBusy ? null : _submit(),
                        validator: (value) => value != _password.text
                            ? l10n.authPasswordMismatch
                            : null,
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                    ],
                    if (auth.errorCode != null) ...[
                      const SizedBox(height: 14),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Text(
                            _errorMessage(l10n, auth.errorCode),
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: auth.isBusy ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: auth.isBusy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _register
                                    ? l10n.authSubmitRegister
                                    : l10n.authSubmitLogin,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: auth.isBusy
                          ? null
                          : () {
                              auth.clearError();
                              setState(() => _register = !_register);
                            },
                      child: Text(
                        _register
                            ? l10n.authBackToLogin
                            : l10n.authCreateAccount,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authGuestStillAvailable,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    String? Function(String?)? validator,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
    Iterable<String>? autofillHints,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    obscureText: obscureText,
    validator: validator,
    onFieldSubmitted: onSubmitted,
    autofillHints:
        autofillHints ?? (obscureText ? const [AutofillHints.password] : null),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
    ),
  );
}
