import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Bottom Navigation Bar premium dengan tombol Home bulat besar di tengah.
/// Layout: Kereta | Tiket | 🏠 HOME (FAB) | Promo | Akun
///
/// Index mapping (tetap sama agar tidak break halaman lain):
///   0 = Beranda, 1 = Kereta, 2 = Tiket, 3 = Promo, 4 = Akun
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  static const List<String> _routes = [
    '/',       // 0: Beranda
    '/timetable', // 1: Jadwal
    '/tiket',  // 2: Tiket Saya
    '/promo',  // 3: Promo
    '/akun',   // 4: Akun
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

    return SizedBox(
      height: 80 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Bar background with notch ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 64 + bottomPadding,
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
                clipper: _NavBarNotchClipper(),
                child: Container(
                  color: AppColors.surface,
                ),
              ),
            ),
          ),

          // ── Tab items (4 tabs, 2 kiri + 2 kanan, kosong di tengah) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  // ── 2 tab kiri ──
                  Expanded(
                    child: _NavItem(
                      icon: Icons.calendar_month_outlined,
                      activeIcon: Icons.calendar_month,
                      label: 'Jadwal',
                      isActive: currentIndex == 1,
                      onTap: () => _onTap(context, 1),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.confirmation_number_outlined,
                      activeIcon: Icons.confirmation_number,
                      label: 'Tiket',
                      isActive: currentIndex == 2,
                      onTap: () => _onTap(context, 2),
                    ),
                  ),

                  // ── Ruang kosong untuk FAB di tengah ──
                  const SizedBox(width: 72),

                  // ── 2 tab kanan ──
                  Expanded(
                    child: _NavItem(
                      icon: Icons.local_offer_outlined,
                      activeIcon: Icons.local_offer,
                      label: 'Promo',
                      isActive: currentIndex == 3,
                      onTap: () => _onTap(context, 3),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Akun',
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
              child: GestureDetector(
                onTap: () => _onTap(context, 0),
                child: Container(
                  width: 60,
                  height: 60,
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
                              AppColors.primaryBlueDark.withValues(alpha: 0.85),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.40),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
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
                        currentIndex == 0 ? Icons.home : Icons.home_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Home',
                        style: TextStyle(
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
    return GestureDetector(
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
    );
  }
}

/// Custom clipper untuk membuat cekungan/notch di tengah navbar
/// agar tombol Home bulat terlihat "duduk" di atas bar.
class _NavBarNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notchRadius = 36;
    const double notchMargin = 6;
    final double centerX = size.width / 2;

    final path = Path();
    path.moveTo(0, 0);

    // Garis lurus dari kiri sampai mendekati notch
    path.lineTo(centerX - notchRadius - notchMargin, 0);

    // Kurva cekungan (notch) untuk tempat FAB
    path.arcToPoint(
      Offset(centerX + notchRadius + notchMargin, 0),
      radius: const Radius.circular(notchRadius),
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
