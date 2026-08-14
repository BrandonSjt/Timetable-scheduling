import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/profile_detail_scaffold.dart';

enum _TicketFilter { all, active, completed }

/// Riwayat tiket yang disimpan pada perangkat selama mode tamu.
class TicketHistoryPage extends StatefulWidget {
  const TicketHistoryPage({super.key});

  @override
  State<TicketHistoryPage> createState() => _TicketHistoryPageState();
}

class _TicketHistoryPageState extends State<TicketHistoryPage> {
  _TicketFilter _filter = _TicketFilter.all;
  bool _showHistory = true;

  bool get _showActive =>
      _filter == _TicketFilter.all || _filter == _TicketFilter.active;

  bool get _showCompleted =>
      _filter == _TicketFilter.all || _filter == _TicketFilter.completed;

  void _clearHistory() {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _showHistory = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.historyCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProfileDetailScaffold(
      title: l10n.historyTitle,
      subtitle: l10n.historySubtitle,
      children: [
        _buildGuestNotice(l10n),
        const SizedBox(height: 20),
        _buildFilters(l10n),
        const SizedBox(height: 24),
        Text(
          l10n.historyLastTicket,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.historySortRecent,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (!_showHistory)
          _buildEmptyState(l10n)
        else ...[
          if (_showActive)
            _TicketHistoryCard(
              lineName: l10n.historyKrl,
              route: l10n.historyKrlRoute,
              date: l10n.historyKrlDate,
              status: l10n.active,
              accentColor: AppColors.primaryBlue,
              badgeColor: const Color(0xFFECFDF3),
              badgeTextColor: const Color(0xFF16A34A),
              onTap: () => context.push('/detail-tiket-aktif'),
              detailLabel: l10n.detail,
            ),
          if (_showActive && _showCompleted) const SizedBox(height: 12),
          if (_showCompleted)
            _TicketHistoryCard(
              lineName: l10n.historyLrt,
              route: l10n.historyLrtRoute,
              date: l10n.historyLrtDate,
              status: l10n.completed,
              accentColor: AppColors.accentOrange,
              badgeColor: AppColors.background,
              badgeTextColor: AppColors.textSecondary,
              onTap: () => context.push('/detail-tiket-selesai'),
              detailLabel: l10n.detail,
            ),
        ],
        const SizedBox(height: 28),
        _buildClearAction(l10n),
      ],
    );
  }

  Widget _buildGuestNotice(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.accentOrangeLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.remove_rounded,
              color: AppColors.accentOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyGuestMode,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.historyGuestDesc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      children: [
        _filterChip(l10n.all, _TicketFilter.all),
        _filterChip(l10n.active, _TicketFilter.active),
        _filterChip(l10n.completed, _TicketFilter.completed),
      ],
    );
  }

  Widget _filterChip(String label, _TicketFilter value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      showCheckmark: false,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.primaryBlue : AppColors.cardBorder,
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.confirmation_num_outlined,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.historyNoTickets,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearAction(AppLocalizations l10n) {
    return Material(
      color: AppColors.primaryBlueLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFBFDBFE)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _showHistory ? _clearHistory : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.historyClearHistory,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.historyClearDesc,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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

class _TicketHistoryCard extends StatelessWidget {
  final String lineName;
  final String route;
  final String date;
  final String status;
  final Color accentColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback onTap;
  final String detailLabel;

  const _TicketHistoryCard({
    required this.lineName,
    required this.route,
    required this.date,
    required this.status,
    required this.accentColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onTap,
    required this.detailLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.train_rounded, color: accentColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lineName,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  route,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(52, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  detailLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
