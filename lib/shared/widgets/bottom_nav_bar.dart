import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Bottom Navigation Bar yang dipakai di semua halaman utama.
/// Menampilkan 5 tab: Beranda, Kereta, Tiket Saya, Promo, Akun.
/// Navigasi antar halaman menggunakan GoRouter.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  static const List<String> _routes = [
    '/',
    '/kereta',
    '/tiket',    // Placeholder
    '/promo',    // Placeholder
    '/akun',     // Placeholder
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return; // Jangan navigasi ke halaman yang sama
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Beranda',
                isActive: currentIndex == 0,
                onTap: () => _onTap(context, 0),
              ),
              _NavItem(
                icon: Icons.train_outlined,
                activeIcon: Icons.train,
                label: 'Kereta',
                isActive: currentIndex == 1,
                onTap: () => _onTap(context, 1),
              ),
              _NavItem(
                icon: Icons.confirmation_number_outlined,
                activeIcon: Icons.confirmation_number,
                label: 'Tiket Saya',
                isActive: currentIndex == 2,
                onTap: () => _onTap(context, 2),
              ),
              _NavItem(
                icon: Icons.local_offer_outlined,
                activeIcon: Icons.local_offer,
                label: 'Promo',
                isActive: currentIndex == 3,
                onTap: () => _onTap(context, 3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Akun',
                isActive: currentIndex == 4,
                onTap: () => _onTap(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryBlue : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primaryBlue : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
