import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/localization/app_locale.dart';
import 'package:timetable/core/localization/locale_controller.dart';
import 'package:timetable/core/localization/locale_provider.dart';
import 'package:timetable/features/auth/domain/entities/account_user.dart';
import 'package:timetable/features/auth/domain/entities/auth_session.dart';
import 'package:timetable/features/auth/domain/repositories/auth_repository.dart';
import 'package:timetable/features/auth/presentation/controllers/auth_controller.dart';
import 'package:timetable/features/auth/presentation/pages/auth_page.dart';
import 'package:timetable/features/auth/presentation/widgets/auth_scope.dart';
import 'package:timetable/features/profile/presentation/pages/profile_page.dart';
import 'package:timetable/l10n/app_localizations.dart';

class _GuestRepository implements AuthRepository {
  @override
  AccountUser? get currentUser => null;

  @override
  Future<AuthBootstrapResult> bootstrap() async => const AuthBootstrapResult();

  @override
  Future<AccountUser> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AccountUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<AccountUser> updateProfile({
    String? name,
    String? phone,
    String? language,
    bool? accessibilityEnabled,
    bool? notificationsEnabled,
  }) => throw UnimplementedError();
}

class _PendingRepository extends _GuestRepository {
  final Completer<AuthBootstrapResult> completer =
      Completer<AuthBootstrapResult>();

  @override
  Future<AuthBootstrapResult> bootstrap() => completer.future;
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  final controller = AuthController(_GuestRepository());
  await controller.bootstrap();
  await tester.pumpWidget(
    LocaleScope(
      notifier: LocaleController(initialLocale: AppLocale.indonesian),
      child: AuthScope(
        controller: controller,
        child: MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('account remains usable while session restore is pending', (
    tester,
  ) async {
    final repository = _PendingRepository();
    final controller = AuthController(repository);
    unawaited(controller.bootstrap());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      LocaleScope(
        notifier: LocaleController(initialLocale: AppLocale.indonesian),
        child: AuthScope(
          controller: controller,
          child: const MaterialApp(
            locale: Locale('id'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProfilePage(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Masuk atau Buat Akun'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('guest account explicitly keeps ticket purchase available', (
    tester,
  ) async {
    await _pump(tester, const ProfilePage());

    expect(find.text('Masuk atau Buat Akun'), findsOneWidget);
    expect(find.textContaining('beli tiket'), findsOneWidget);
  });

  testWidgets('registration requires a password confirmation field', (
    tester,
  ) async {
    await _pump(tester, const AuthPage(register: true));

    expect(find.text('Nama lengkap'), findsOneWidget);
    expect(find.text('Nomor telepon (opsional)'), findsOneWidget);
    expect(find.text('Ulangi kata sandi'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });
}
