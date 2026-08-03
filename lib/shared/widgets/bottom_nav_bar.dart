import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Bottom Navigation Bar premium dengan tombol Home bulat besar di tengah.
/// Layout: Kereta | Tiket | Home | Asisten | Akun
///
/// Index mapping (tetap sama agar tidak break halaman lain):
///   0 = Beranda, 1 = Kereta, 2 = Tiket, 3 = Asisten, 4 = Akun
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, this.currentIndex = 0});

  static const List<String> _routes = [
    '/', // 0: Beranda
    '/timetable', // 1: Jadwal
    '/tiket', // 2: Tiket Saya
    '/asisten', // 3: Asisten
    '/akun', // 4: Akun
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) {
      if (index == 0) {
        // Jika sudah di Home, tap Home akan membersihkan query parameter dan menutup panel info stasiun
        context.go('/');
      }
      return;
    }
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final scaleProgress = ((textScale - 1) / 1).clamp(0.0, 1.0);
    final navHeight = 64.0 + (52 * scaleProgress);
    final homeSize = 60.0 + (24 * scaleProgress);

    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: navHeight + 16 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Bar background with notch ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: navHeight + bottomPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: _NavBarNotchClipper(notchRadius: homeSize / 2 + 6),
                child: Container(color: AppColors.surface),
              ),
            ),
          ),

          // ── Tab items (4 tabs, 2 kiri + 2 kanan, kosong di tengah) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            child: SizedBox(
              height: navHeight,
              child: Row(
                children: [
                  // ── 2 tab kiri ──
                  Expanded(
                    child: _NavItem(
                      icon: Icons.calendar_month_outlined,
                      activeIcon: Icons.calendar_month_rounded,
                      label: l10n.navSchedule,
                      isActive: currentIndex == 1,
                      onTap: () => _onTap(context, 1),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.confirmation_num_outlined,
                      activeIcon: Icons.confirmation_num_rounded,
                      label: l10n.navTickets,
                      isActive: currentIndex == 2,
                      onTap: () => _onTap(context, 2),
                    ),
                  ),

                  // ── Ruang kosong untuk FAB di tengah ──
                  SizedBox(width: homeSize + 12),

                  // ── 2 tab kanan ──
                  Expanded(
                    child: _NavItem(
                      icon: Icons.headset_mic_outlined,
                      activeIcon: Icons.headset_mic_rounded,
                      label: l10n.navAssistant,
                      isActive: currentIndex == 3,
                      onTap: () => _onTap(context, 3),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: l10n.navAccount,
                      isActive: currentIndex == 4,
                      onTap: () => _onTap(context, 4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tombol Home bulat besar (FAB) di tengah ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Semantics(
                button: true,
                selected: currentIndex == 0,
                label: 'Home',
                onTap: () => _onTap(context, 0),
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: () => _onTap(context, 0),
                    child: Container(
                      width: homeSize,
                      height: homeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: currentIndex == 0
                              ? [
                                  AppColors.primaryBlue,
                                  AppColors.primaryBlueDark,
                                ]
                              : [
                                  AppColors.primaryBlue.withValues(alpha: 0.85),
                                  AppColors.primaryBlueDark.withValues(
                                    alpha: 0.85,
                                  ),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.40,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            currentIndex == 0
                                ? Icons.home_rounded
                                : Icons.home_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            l10n.navHome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item navigasi individual (ikon + label)
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primaryBlue : AppColors.textHint,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.primaryBlue : AppColors.textHint,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom clipper untuk membuat cekungan/notch di tengah navbar
/// agar tombol Home bulat terlihat "duduk" di atas bar.
class _NavBarNotchClipper extends CustomClipper<Path> {
  final double notchRadius;

  const _NavBarNotchClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    const double notchMargin = 6;
    final double centerX = size.width / 2;

    final path = Path();
    path.moveTo(0, 0);

    // Garis lurus dari kiri sampai mendekati notch
    path.lineTo(centerX - notchRadius - notchMargin, 0);

    // Kurva cekungan (notch) untuk tempat FAB
    path.arcToPoint(
      Offset(centerX + notchRadius + notchMargin, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Garis lurus dari notch sampai kanan
    path.lineTo(size.width, 0);

    // Sisi kanan, bawah, kiri (tutup kotak)
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _NavBarNotchClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius;
}
