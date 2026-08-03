import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _ScheduleIssue {
  late,
  missingTrain,
  changedSchedule,
  differentPlatform;
}

extension _ScheduleIssueL10n on _ScheduleIssue {
  String label(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaLabel,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainLabel,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleLabel,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformLabel,
    };
  }

  String title(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaTitle,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainTitle,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleTitle,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformTitle,
    };
  }

  String activeLabel(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaActive,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainActive,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleActive,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformActive,
    };
  }

  String route(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaRoute,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainRoute,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleRoute,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformRoute,
    };
  }

  String routeDetail(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaRouteDetail,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainRouteDetail,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleRouteDetail,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformRouteDetail,
    };
  }

  String note(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaNote,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainNote,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleNote,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformNote,
    };
  }

  String guidance(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaGuidance,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainGuidance,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleGuidance,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformGuidance,
    };
  }

  String actionLabel(AppLocalizations l10n) {
    return switch (this) {
      _ScheduleIssue.late => l10n.issueLateEtaAction,
      _ScheduleIssue.missingTrain => l10n.issueMissingTrainAction,
      _ScheduleIssue.changedSchedule => l10n.issueChangedScheduleAction,
      _ScheduleIssue.differentPlatform => l10n.issueDiffPlatformAction,
    };
  }
}

class ScheduleIssuePage extends StatefulWidget {
  const ScheduleIssuePage({super.key});

  @override
  State<ScheduleIssuePage> createState() => _ScheduleIssuePageState();
}

class _ScheduleIssuePageState extends State<ScheduleIssuePage> {
  _ScheduleIssue _issue = _ScheduleIssue.late;

  void _selectIssue(String label, AppLocalizations l10n) {
    setState(() {
      _issue = _ScheduleIssue.values.firstWhere(
        (issue) => issue.label(l10n) == label,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ProfileDetailScaffold(
      title: _issue.title(l10n),
      subtitle: l10n.issueReportMismatch,
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.accentOrange,
          iconBackground: const Color(0xFFFFF1E8),
          title: l10n.issueScheduleAndEta,
          status: l10n.issueActiveProblem(_issue.activeLabel(l10n)),
          description: l10n.issueDetailFollows,
        ),
        const SizedBox(height: 28),
        HelpFieldCard(
          label: l10n.issueMonitoredRoute,
          value: _issue.route(l10n),
          supportingText: _issue.routeDetail(l10n),
        ),
        const SizedBox(height: 28),
        HelpSectionHeading(title: l10n.issueProblemOccurred),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: _ScheduleIssue.values.map((issue) => issue.label(l10n)).toList(),
          selected: _issue.label(l10n),
          onSelected: (label) => _selectIssue(label, l10n),
          columns: 2,
          accentColor: AppColors.accentOrange,
          selectedBackground: const Color(0xFFFFF1E8),
        ),
        const SizedBox(height: 28),
        HelpFieldCard(label: l10n.issueNotes, value: _issue.note(l10n)),
        const SizedBox(height: 18),
        HelpSurfaceCard(
          color: const Color(0xFFE8F8F0),
          borderColor: const Color(0xFFB7E9D2),
          child: Text(
            _issue.guidance(l10n),
            style: const TextStyle(
              color: Color(0xFF079669),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 22),
        HelpPrimaryButton(
          label: _issue.actionLabel(l10n),
          color: AppColors.accentOrange,
          onPressed: () => showHelpMessage(
            context,
            l10n.issueCorrectionPrepared(_issue.activeLabel(l10n).toLowerCase()),
          ),
        ),
      ],
    );
  }
}
