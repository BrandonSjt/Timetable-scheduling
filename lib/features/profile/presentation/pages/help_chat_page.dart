import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/support_chat_topic.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

class HelpChatPage extends StatefulWidget {
  const HelpChatPage({super.key});

  @override
  State<HelpChatPage> createState() => _HelpChatPageState();
}

class _HelpChatPageState extends State<HelpChatPage> {
  SupportChatTopic _topic = SupportChatTopic.ticket;

  void _selectTopic(String label, AppLocalizations l10n) {
    setState(() {
      _topic = SupportChatTopic.values.firstWhere(
        (topic) => topic.label(l10n) == label,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ProfileDetailScaffold(
      title: _topic.title(l10n),
      subtitle: l10n.chatLiveHelp,
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.primaryBlue,
          iconBackground: AppColors.primaryBlueLight,
          title: l10n.chatWithStaff,
          status: l10n.chatActiveTopic(_topic.label(l10n)),
          description: l10n.chatContentTailored,
        ),
        const SizedBox(height: 28),
        HelpSectionHeading(
          title: l10n.chatServiceStatus,
          subtitle: l10n.chatWaitEstimate,
        ),
        const SizedBox(height: 16),
        HelpSurfaceCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF17A871),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _topic.availability(l10n),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _topic.waitTime(l10n),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        HelpSectionHeading(title: l10n.chatSelectTopic),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: SupportChatTopic.values
              .map((topic) => topic.label(l10n))
              .toList(),
          selected: _topic.label(l10n),
          onSelected: (label) => _selectTopic(label, l10n),
          columns: 3,
          accentColor: AppColors.primaryBlue,
          selectedBackground: AppColors.primaryBlueLight,
        ),
        const SizedBox(height: 22),
        HelpFieldCard(
          label: l10n.chatInitialMessage,
          value: _topic.openingMessage(l10n),
        ),
        const SizedBox(height: 14),
        HelpFieldCard(
          label: l10n.chatSharedData,
          value: _topic.sharedData(l10n),
        ),
        const SizedBox(height: 22),
        HelpPrimaryButton(
          label: _topic.actionLabel(l10n),
          color: AppColors.primaryBlue,
          onPressed: () => context.push(
            Uri(
              path: '/bantuan/chat/percakapan',
              queryParameters: {'topic': _topic.key},
            ).toString(),
          ),
        ),
      ],
    );
  }
}
