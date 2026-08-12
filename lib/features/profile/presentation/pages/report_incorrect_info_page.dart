import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _ReportType {
  schedule,
  route,
  station;
}

extension _ReportTypeL10n on _ReportType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleLabel,
      _ReportType.route => l10n.reportRouteLabel,
      _ReportType.station => l10n.reportStationLabel,
    };
  }

  String title(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleTitle,
      _ReportType.route => l10n.reportRouteTitle,
      _ReportType.station => l10n.reportStationTitle,
    };
  }

  String firstLabel(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleFirstLabel,
      _ReportType.route => l10n.reportRouteFirstLabel,
      _ReportType.station => l10n.reportStationFirstLabel,
    };
  }

  String firstValue(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleFirstValue,
      _ReportType.route => l10n.reportRouteFirstValue,
      _ReportType.station => l10n.reportStationFirstValue,
    };
  }

  String secondLabel(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleSecondLabel,
      _ReportType.route => l10n.reportRouteSecondLabel,
      _ReportType.station => l10n.reportStationSecondLabel,
    };
  }

  String secondValue(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleSecondValue,
      _ReportType.route => l10n.reportRouteSecondValue,
      _ReportType.station => l10n.reportStationSecondValue,
    };
  }

  String description(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleDesc,
      _ReportType.route => l10n.reportRouteDesc,
      _ReportType.station => l10n.reportStationDesc,
    };
  }

  String actionLabel(AppLocalizations l10n) {
    return switch (this) {
      _ReportType.schedule => l10n.reportScheduleAction,
      _ReportType.route => l10n.reportRouteAction,
      _ReportType.station => l10n.reportStationAction,
    };
  }
}

class ReportIncorrectInfoPage extends StatefulWidget {
  const ReportIncorrectInfoPage({super.key});

  @override
  State<ReportIncorrectInfoPage> createState() =>
      _ReportIncorrectInfoPageState();
}

class _ReportIncorrectInfoPageState extends State<ReportIncorrectInfoPage> {
  _ReportType _type = _ReportType.schedule;

  void _selectType(String label, AppLocalizations l10n) {
    setState(() {
      _type = _ReportType.values.firstWhere((type) => type.label(l10n) == label);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ProfileDetailScaffold(
      title: _type.title(l10n),
      subtitle: l10n.reportSubtitle,
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.accentOrange,
          iconBackground: const Color(0xFFFFF1E8),
          title: l10n.reportWrongInfo,
          status: l10n.reportTypePrefix(_type.label(l10n)),
          description: l10n.reportFieldsDesc,
        ),
        const SizedBox(height: 28),
        HelpSectionHeading(title: l10n.reportTypeHeading),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: _ReportType.values.map((type) => type.label(l10n)).toList(),
          selected: _type.label(l10n),
          onSelected: (label) => _selectType(label, l10n),
          columns: 3,
          accentColor: AppColors.accentOrange,
          selectedBackground: const Color(0xFFFFF1E8),
        ),
        const SizedBox(height: 22),
        HelpFieldCard(label: _type.firstLabel(l10n), value: _type.firstValue(l10n)),
        const SizedBox(height: 14),
        HelpFieldCard(label: _type.secondLabel(l10n), value: _type.secondValue(l10n)),
        const SizedBox(height: 14),
        HelpFieldCard(label: l10n.reportDescLabel, value: _type.description(l10n)),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () => showHelpMessage(
            context,
            l10n.reportAttachScreenshotMsg,
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.reportAttachScreenshot),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentOrange,
            minimumSize: const Size.fromHeight(52),
            alignment: AlignmentDirectional.centerStart,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            side: const BorderSide(color: Color(0xFFFDBA74)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        HelpPrimaryButton(
          label: _type.actionLabel(l10n),
          color: AppColors.accentOrange,
          onPressed: () => showHelpMessage(
            context,
            l10n.reportPrepared(_type.label(l10n).toLowerCase()),
          ),
        ),
      ],
    );
  }
}
