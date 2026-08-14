import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/profile_detail_scaffold.dart';

class _HelpTopic {
  final String title;
  final String subtitle;
  final String route;

  const _HelpTopic(this.title, this.subtitle, this.route);
}

List<_HelpTopic> _getHelpTopics(AppLocalizations l10n) => [
  _HelpTopic(
    l10n.helpTopicBuyTicket,
    l10n.helpTopicBuyTicketDesc,
    '/bantuan/chat',
  ),
  _HelpTopic(
    l10n.helpTopicScheduleIssue,
    l10n.helpTopicScheduleIssueDesc,
    '/bantuan/jadwal-eta',
  ),
  _HelpTopic(
    l10n.helpTopicPaymentIssue,
    l10n.helpTopicPaymentIssueDesc,
    '/bantuan/pembayaran',
  ),
];

/// Pusat bantuan mode tamu dengan pencarian dan pintasan dukungan.
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  String _query = '';

  List<_HelpTopic> _getVisibleTopics(AppLocalizations l10n) {
    final query = _query.trim().toLowerCase();
    final topics = _getHelpTopics(l10n);
    if (query.isEmpty) return topics;
    return topics
        .where(
          (topic) =>
              topic.title.toLowerCase().contains(query) ||
              topic.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topics = _getVisibleTopics(l10n);

    return ProfileDetailScaffold(
      title: l10n.helpCenterTitle,
      subtitle: l10n.helpCenterSubtitle,
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.helpSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          l10n.helpQuickActions,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.helpQuickActionsDesc,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _QuickHelpAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: l10n.helpChatStaff,
                iconColor: AppColors.primaryBlue,
                iconBackground: AppColors.primaryBlueLight,
                onTap: () => context.push('/bantuan/chat'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickHelpAction(
                icon: Icons.report_outlined,
                label: l10n.helpReportInfo,
                iconColor: AppColors.accentOrange,
                iconBackground: AppColors.accentOrangeLight,
                onTap: () => context.push('/bantuan/lapor'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text(
          l10n.helpTopicsTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        if (topics.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              l10n.helpNoTopicsFound,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          )
        else
          for (var index = 0; index < topics.length; index++) ...[
            _HelpTopicTile(
              topic: topics[index],
              onTap: () => context.push(topics[index].route),
            ),
            if (index != topics.length - 1) const SizedBox(height: 10),
          ],
        const SizedBox(height: 24),
        Material(
          color: AppColors.accentOrangeLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: AppColors.pinkAccent.withValues(alpha: 0.45),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showMessage(l10n.helpCallKaiSnack),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.helpCallKai,
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.accentOrange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickHelpAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const _QuickHelpAction({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpTopicTile extends StatelessWidget {
  final _HelpTopic topic;
  final VoidCallback onTap;

  const _HelpTopicTile({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
