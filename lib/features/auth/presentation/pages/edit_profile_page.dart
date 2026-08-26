import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_scope.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final user = AuthScope.of(context, listen: false).user;
    _name = TextEditingController(text: user?.name);
    _phone = TextEditingController(text: user?.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? l10n.authNameRequired
                  : null,
              decoration: InputDecoration(
                labelText: l10n.authName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.authPhoneOptional,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.isBusy
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final ok = await auth.updateProfile(
                        name: _name.text.trim(),
                        phone: _phone.text.trim(),
                      );
                      if (ok && context.mounted) context.pop();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size.fromHeight(52),
              ),
              child: auth.isBusy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.saveChanges),
            ),
            if (auth.errorCode != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.authNetworkError,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
