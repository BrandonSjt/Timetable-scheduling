import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/assistant_controller.dart';

class AssistantResponsePanel extends StatelessWidget {
  const AssistantResponsePanel({
    super.key,
    required this.state,
    required this.userTranscript,
    required this.assistantResponse,
    required this.onConfirm,
    required this.onRepeat,
    required this.onCancel,
    required this.onRetry,
  });

  final AssistantInteractionState state;
  final String? userTranscript;
  final String? assistantResponse;
  final VoidCallback onConfirm;
  final VoidCallback onRepeat;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (userTranscript == null && assistantResponse == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final isError = state == AssistantInteractionState.error;
    final needsConfirmation = state == AssistantInteractionState.confirmation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? AppColors.statusRed.withValues(alpha: 0.45)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userTranscript != null) ...[
            _MessageLabel(icon: Icons.person_rounded, label: l10n.chatUser),
            const SizedBox(height: 6),
            Text(
              userTranscript!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
          if (userTranscript != null && assistantResponse != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider),
            ),
          if (assistantResponse != null) ...[
            _MessageLabel(
              icon: Icons.headset_mic_rounded,
              label: l10n.assistantChatAssistant,
            ),
            const SizedBox(height: 6),
            Semantics(
              liveRegion: true,
              child: Text(
                assistantResponse!,
                style: TextStyle(
                  color: isError ? AppColors.statusRed : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (needsConfirmation) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.route_rounded, size: 20),
                label: Text(l10n.assistantUseThisRoute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: onRepeat,
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: Text(l10n.assistantRepeat),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(l10n.assistantCancel),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (isError) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(l10n.assistantRetry),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageLabel extends StatelessWidget {
  const _MessageLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
