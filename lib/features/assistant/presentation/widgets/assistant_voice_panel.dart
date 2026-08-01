import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/assistant_controller.dart';

class AssistantVoicePanel extends StatelessWidget {
  const AssistantVoicePanel({
    super.key,
    required this.state,
    required this.onTap,
  });

  final AssistantInteractionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final presentation = _VoicePresentation.forState(state);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            presentation.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            presentation.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Semantics(
            button: true,
            enabled: onTap != null,
            label: presentation.semanticLabel,
            value: presentation.prompt,
            onTap: onTap,
            child: ExcludeSemantics(
              child: Material(
                color: presentation.color,
                shape: const CircleBorder(),
                elevation: state == AssistantInteractionState.listening ? 1 : 4,
                shadowColor: presentation.color.withValues(alpha: 0.28),
                child: InkWell(
                  key: const Key('assistant-microphone-button'),
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: Icon(
                      presentation.icon,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _VoiceLevelIndicator(
            active:
                state == AssistantInteractionState.listening ||
                state == AssistantInteractionState.speaking,
            color: presentation.color,
          ),
        ],
      ),
    );
  }
}

class _VoiceLevelIndicator extends StatelessWidget {
  const _VoiceLevelIndicator({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const heights = [8.0, 15.0, 23.0, 15.0, 8.0];
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: heights
            .map(
              (height) => Container(
                width: 4,
                height: active ? height : 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active ? color : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _VoicePresentation {
  const _VoicePresentation({
    required this.prompt,
    required this.description,
    required this.semanticLabel,
    required this.icon,
    required this.color,
  });

  final String prompt;
  final String description;
  final String semanticLabel;
  final IconData icon;
  final Color color;

  factory _VoicePresentation.forState(AssistantInteractionState state) {
    return switch (state) {
      AssistantInteractionState.ready => const _VoicePresentation(
        prompt: 'Ketuk untuk bicara',
        description: 'Mau ke mana hari ini?',
        semanticLabel: 'Mulai percakapan suara',
        icon: Icons.mic_rounded,
        color: AppColors.primaryBlue,
      ),
      AssistantInteractionState.listening => const _VoicePresentation(
        prompt: 'Mendengarkan',
        description: 'Silakan sebutkan tujuan perjalanan',
        semanticLabel: 'Hentikan percakapan suara',
        icon: Icons.stop_rounded,
        color: AppColors.accentOrange,
      ),
      AssistantInteractionState.processing => const _VoicePresentation(
        prompt: 'Memproses permintaan',
        description: 'Mencari pilihan perjalanan yang sesuai',
        semanticLabel: 'Permintaan sedang diproses',
        icon: Icons.hourglass_top_rounded,
        color: AppColors.buttonDark,
      ),
      AssistantInteractionState.speaking => const _VoicePresentation(
        prompt: 'Agent sedang berbicara',
        description: 'Jawaban perjalanan sedang dibacakan',
        semanticLabel: 'Hentikan suara asisten',
        icon: Icons.stop_rounded,
        color: AppColors.statusGreen,
      ),
      AssistantInteractionState.confirmation => const _VoicePresentation(
        prompt: 'Perlu konfirmasi',
        description: 'Pilih tindakan sebelum membuka rute',
        semanticLabel: 'Mulai percakapan baru',
        icon: Icons.mic_rounded,
        color: AppColors.primaryBlue,
      ),
      AssistantInteractionState.error => const _VoicePresentation(
        prompt: 'Coba lagi',
        description: 'Gunakan suara atau pilih tindakan cepat',
        semanticLabel: 'Coba percakapan suara lagi',
        icon: Icons.refresh_rounded,
        color: AppColors.statusRed,
      ),
    };
  }
}
