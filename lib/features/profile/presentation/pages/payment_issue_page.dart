import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/help_flow_widgets.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _PaymentIssue {
  deductedBalance,
  missingTicket,
  refund,
  paymentMethod;
}

extension _PaymentIssueL10n on _PaymentIssue {
  String label(AppLocalizations l10n) {
    return switch (this) {
      _PaymentIssue.deductedBalance => l10n.payDeductedLabel,
      _PaymentIssue.missingTicket => l10n.payMissingLabel,
      _PaymentIssue.refund => l10n.payRefundLabel,
      _PaymentIssue.paymentMethod => l10n.payMethodLabel,
    };
  }

  String title(AppLocalizations l10n) {
    return switch (this) {
      _PaymentIssue.deductedBalance => l10n.payDeductedTitle,
      _PaymentIssue.missingTicket => l10n.payMissingTitle,
      _PaymentIssue.refund => l10n.payRefundTitle,
      _PaymentIssue.paymentMethod => l10n.payMethodTitle,
    };
  }

  String status(AppLocalizations l10n) {
    return switch (this) {
      _PaymentIssue.deductedBalance => l10n.payDeductedStatus,
      _PaymentIssue.missingTicket => l10n.payMissingStatus,
      _PaymentIssue.refund => l10n.payRefundStatus,
      _PaymentIssue.paymentMethod => l10n.payMethodStatus,
    };
  }

  String transactionDetail(AppLocalizations l10n) {
    return switch (this) {
      _PaymentIssue.deductedBalance => l10n.payDeductedDetail,
      _PaymentIssue.missingTicket => l10n.payMissingDetail,
      _PaymentIssue.refund => l10n.payRefundDetail,
      _PaymentIssue.paymentMethod => l10n.payMethodDetail,
    };
  }

  String advice(AppLocalizations l10n) {
    return switch (this) {
      _PaymentIssue.deductedBalance => l10n.payDeductedAdvice,
      _PaymentIssue.missingTicket => l10n.payMissingAdvice,
      _PaymentIssue.refund => l10n.payRefundAdvice,
      _PaymentIssue.paymentMethod => l10n.payMethodAdvice,
    };
  }

  String actionLabel(AppLocalizations l10n) {
    return switch (this) {
      _PaymentIssue.deductedBalance => l10n.payDeductedAction,
      _PaymentIssue.missingTicket => l10n.payMissingAction,
      _PaymentIssue.refund => l10n.payRefundAction,
      _PaymentIssue.paymentMethod => l10n.payMethodAction,
    };
  }
}

class PaymentIssuePage extends StatefulWidget {
  const PaymentIssuePage({super.key});

  @override
  State<PaymentIssuePage> createState() => _PaymentIssuePageState();
}

class _PaymentIssuePageState extends State<PaymentIssuePage> {
  _PaymentIssue _issue = _PaymentIssue.deductedBalance;

  void _selectIssue(String label, AppLocalizations l10n) {
    setState(() {
      _issue = _PaymentIssue.values.firstWhere((issue) => issue.label(l10n) == label);
    });
  }

  Color get _statusColor {
    return switch (_issue) {
      _PaymentIssue.missingTicket => AppColors.statusGreen,
      _PaymentIssue.paymentMethod => AppColors.statusRed,
      _ => AppColors.accentOrange,
    };
  }

  Color get _statusBackground {
    return switch (_issue) {
      _PaymentIssue.missingTicket => const Color(0xFFE8F8F0),
      _PaymentIssue.paymentMethod => const Color(0xFFFEECEC),
      _ => const Color(0xFFFFF1E8),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ProfileDetailScaffold(
      title: _issue.title(l10n),
      subtitle: l10n.payCheckStatusSubtitle,
      fallbackRoute: '/pusat-bantuan',
      children: [
        HelpIntroCard(
          icon: Icons.add_rounded,
          accentColor: AppColors.primaryBlue,
          iconBackground: const Color(0xFFEAF2FF),
          title: l10n.payIssueTitle,
          status: l10n.payActiveIssue(_issue.label(l10n)),
          description: l10n.payIssueDescription,
        ),
        const SizedBox(height: 28),
        HelpFieldCard(
          label: l10n.payLastTransaction,
          value: 'KRL-2407-0812',
          supportingText: _issue.transactionDetail(l10n),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _statusBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _issue.status(l10n),
              style: TextStyle(
                color: _statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        HelpSectionHeading(title: l10n.paySelectIssue),
        const SizedBox(height: 16),
        HelpChoiceGrid(
          options: _PaymentIssue.values.map((issue) => issue.label(l10n)).toList(),
          selected: _issue.label(l10n),
          onSelected: (label) => _selectIssue(label, l10n),
          columns: 2,
          accentColor: AppColors.primaryBlue,
          selectedBackground: const Color(0xFFEAF2FF),
        ),
        const SizedBox(height: 28),
        HelpFieldCard(label: l10n.payQuickAdvice, value: _issue.advice(l10n)),
        const SizedBox(height: 22),
        HelpPrimaryButton(
          label: _issue.actionLabel(l10n),
          color: AppColors.primaryBlue,
          onPressed: () => showHelpMessage(
            context,
            l10n.payHelpPrepared(_issue.label(l10n).toLowerCase()),
          ),
        ),
      ],
    );
  }
}
