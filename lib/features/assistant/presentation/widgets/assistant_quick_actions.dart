import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AssistantQuickAction {
  const AssistantQuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class AssistantQuickActions extends StatelessWidget {
  const AssistantQuickActions({super.key, required this.actions});

  final List<AssistantQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actions
              .map(
                (action) => SizedBox(
                  width: itemWidth,
                  height: 72,
                  child: Semantics(
                    button: true,
                    label: l10n.assistantOpenQuickAction(action.label),
                    onTap: action.onTap,
                    child: ExcludeSemantics(
                      child: Material(
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.cardBorder),
                        ),
                        child: InkWell(
                          onTap: action.onTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Icon(
                                  action.icon,
                                  size: 22,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    action.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
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
              )
              .toList(),
        );
      },
    );
  }
}
