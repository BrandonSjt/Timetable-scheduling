import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/widgets/auth_scope.dart';
import '../../../auth/domain/entities/account_user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthScope.of(context);
    final user = auth.user;
    final isEnglish = LocaleScope.of(context).value.languageCode == 'en';
    final offline = auth.status == AuthStatus.offlineAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF4F46E5),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileAccount,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user == null
                        ? l10n.profileGuestModeActive
                        : offline
                        ? l10n.profileOfflineSession
                        : l10n.profileSignedIn,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                children: [
                  _AccountCard(user: user, offline: offline),
                  const SizedBox(height: 24),
                  _menu(
                    title: user == null
                        ? l10n.profileLocalTicketHistory
                        : l10n.profileAccountTicketHistory,
                    subtitle: user == null
                        ? l10n.profileSavedOnDevice
                        : l10n.profileSyncedAccount,
                    onTap: () => context.push('/riwayat-tiket'),
                  ),
                  const SizedBox(height: 12),
                  _menu(
                    title: l10n.languagePageTitle,
                    subtitle: isEnglish
                        ? l10n.languageEnglish
                        : l10n.languageIndonesian,
                    onTap: () => context.push('/bahasa'),
                  ),
                  const SizedBox(height: 12),
                  _menu(
                    title: l10n.profileAccessibility,
                    subtitle: l10n.profileLargeText,
                    onTap: () => context.push('/aksesibilitas'),
                  ),
                  const SizedBox(height: 12),
                  _menu(
                    title: l10n.profileHelpCenter,
                    subtitle: l10n.profileContactOfficer,
                    onTap: () => context.push('/pusat-bantuan'),
                  ),
                ],
              ),
            ),
            const AppBottomNavBar(currentIndex: 4),
          ],
        ),
      ),
    );
  }

  static Widget _menu({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
    ),
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.offline});

  final AccountUser? user;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthScope.of(context, listen: false);
    final signedIn = user != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: signedIn
                ? AppColors.primaryBlue
                : const Color(0xFFE97D13),
            child: Icon(
              signedIn ? Icons.person_rounded : Icons.remove,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signedIn ? (user!.name ?? user!.email) : l10n.profileGuest,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  signedIn ? user!.email : l10n.profileGuestDesc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (offline) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.profileOfflineHint,
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (!signedIn)
                  FilledButton.tonal(
                    onPressed: () => context.push('/masuk'),
                    child: Text(l10n.profileOptionalLogin),
                  )
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => context.push('/profil-saya'),
                        child: Text(l10n.profileEdit),
                      ),
                      TextButton(
                        onPressed: () => _confirmLogout(context, auth),
                        child: Text(
                          l10n.profileLogout,
                          style: const TextStyle(color: Color(0xFFB91C1C)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthController auth) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileLogout),
        content: Text(l10n.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.profileCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.profileLogout),
          ),
        ],
      ),
    );
    if (confirmed == true) await auth.logout();
  }
}
