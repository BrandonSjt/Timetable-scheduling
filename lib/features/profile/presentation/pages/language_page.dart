import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _AppLanguage { indonesia, english }

/// Pilihan bahasa aplikasi untuk mode tamu.
class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  _AppLanguage _selectedLanguage = _AppLanguage.indonesia;

  String get _languageLabel =>
      _selectedLanguage == _AppLanguage.indonesia ? 'Indonesia' : 'English';

  void _applyLanguage() {
    final message = _selectedLanguage == _AppLanguage.indonesia
        ? 'Bahasa Indonesia diterapkan.'
        : 'English applied.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final useEnglish = _selectedLanguage == _AppLanguage.english;

    return ProfileDetailScaffold(
      title: 'Bahasa',
      subtitle: _languageLabel,
      children: [
        const Text(
          'Bahasa aplikasi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pilih bahasa untuk navigasi dan pesan aplikasi',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _LanguageOption(
          title: 'Indonesia',
          subtitle: 'Bahasa yang sedang digunakan',
          selected: !useEnglish,
          onTap: () {
            setState(() => _selectedLanguage = _AppLanguage.indonesia);
          },
        ),
        const SizedBox(height: 12),
        _LanguageOption(
          title: 'English',
          subtitle: 'Use English for app labels',
          selected: useEnglish,
          onTap: () {
            setState(() => _selectedLanguage = _AppLanguage.english);
          },
        ),
        const SizedBox(height: 52),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pratinjau',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                useEnglish ? 'Account' : 'Akun',
                style: const TextStyle(
                  color: Color(0xFF632BFF),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                useEnglish ? 'Guest mode active' : 'Mode tamu aktif',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 42),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _applyLanguage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Terapkan bahasa',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 36),
        const Center(
          child: Text(
            'Perubahan diterapkan langsung setelah dipilih.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 26,
                  height: 26,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primaryBlue : Colors.white,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textHint,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
