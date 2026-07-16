import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Shell visual bersama untuk seluruh halaman detail dari menu Akun.
///
/// Shell ini mempertahankan header indigo, permukaan atas membulat, tombol
/// kembali, dan tidak menampilkan navigasi bawah.
class ProfileDetailScaffold extends StatelessWidget {
  static const Color headerColor = Color(0xFF4F46E5);
  static const Color pageBackground = Color(0xFFF1F5F9);

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String fallbackRoute;
  final EdgeInsetsGeometry bodyPadding;

  const ProfileDetailScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.fallbackRoute = '/akun',
    this.bodyPadding = const EdgeInsets.fromLTRB(28, 28, 28, 32),
  });

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(fallbackRoute);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: headerColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: pageBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageBackground,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: headerColor,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 24, 50),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Kembali',
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _goBack(context),
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: pageBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ListView(padding: bodyPadding, children: children),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
