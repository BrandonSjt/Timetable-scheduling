import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_detail_scaffold.dart';

/// Halaman pengaturan aksesibilitas yang dibuka dari menu Akun.
class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  bool _highContrast = true;
  bool _largeText = false;
  bool _readRoute = true;
  bool _reduceMotion = false;

  void _readPreview() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Membacakan: Dukuh Atas ke Harjamukti, Peron 2, tiba 4 menit lagi.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailScaffold(
      title: 'Aksesibilitas',
      subtitle: 'Kontras, teks, dan suara',
      children: [
        const Text(
          'Pengaturan tampilan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Buat aplikasi lebih mudah dibaca dan didengar',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        _AccessibilitySwitchTile(
          title: 'Kontras tinggi',
          subtitle: 'Naikkan kontras teks dan tombol',
          value: _highContrast,
          onChanged: (value) => setState(() => _highContrast = value),
        ),
        const SizedBox(height: 12),
        _AccessibilitySwitchTile(
          title: 'Teks besar',
          subtitle: 'Perbesar label dan informasi rute',
          value: _largeText,
          onChanged: (value) => setState(() => _largeText = value),
        ),
        const SizedBox(height: 12),
        _AccessibilitySwitchTile(
          title: 'Bacakan rute',
          subtitle: 'Aktifkan pembacaan stasiun dan arah',
          value: _readRoute,
          onChanged: (value) => setState(() => _readRoute = value),
        ),
        const SizedBox(height: 12),
        _AccessibilitySwitchTile(
          title: 'Kurangi animasi',
          subtitle: 'Batasi gerak saat berpindah halaman',
          value: _reduceMotion,
          onChanged: (value) => setState(() => _reduceMotion = value),
        ),
        const SizedBox(height: 42),
        _buildContrastPreview(),
      ],
    );
  }

  Widget _buildContrastPreview() {
    return Semantics(
      container: true,
      label:
          'Pratinjau kontras. Dukuh Atas ke Harjamukti. Peron 2, tiba 4 menit lagi.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pratinjau kontras',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dukuh Atas → Harjamukti',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Peron 2, tiba 4 menit lagi',
                    style: TextStyle(
                      color: Color(0xFFD0D5DD),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _readRoute ? _readPreview : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A12),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF475467),
                      disabledForegroundColor: const Color(0xFFD0D5DD),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Baca',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessibilitySwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AccessibilitySwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      button: true,
      label: title,
      hint: subtitle,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 17, 18, 17),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primaryBlue,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFCBD5E1),
                  trackOutlineColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
