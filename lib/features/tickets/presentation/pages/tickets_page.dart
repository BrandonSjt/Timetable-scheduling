import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../travel_alarm/presentation/controllers/travel_alarm_controller.dart';
import '../../../travel_alarm/presentation/widgets/travel_alarm_button.dart';
import '../../../travel_alarm/presentation/widgets/travel_alarm_disable_dialog.dart';
import '../../../travel_alarm/presentation/widgets/travel_alarm_setup_sheet.dart';

enum _TicketViewMode { list, checkout, active }

enum _TicketStatus { pending, active, completed }

class _TicketItem {
  final String from;
  final String to;
  final String fare;
  final String serviceInfo;
  final String validityText;
  final _TicketStatus status;

  const _TicketItem({
    required this.from,
    required this.to,
    required this.fare,
    required this.serviceInfo,
    required this.validityText,
    required this.status,
  });
}

/// Halaman Tiket Saya (Screen 09 di Figma)
/// Menampilkan alur checkout tiket dan tiket QR aktif dengan simulasi pembayaran.
class TicketsPage extends StatefulWidget {
  final TravelAlarmController? alarmController;
  final String? from;
  final String? to;
  final String? fare;
  final String? duration;
  final String? transit;

  const TicketsPage({
    super.key,
    this.alarmController,
    this.from,
    this.to,
    this.fare,
    this.duration,
    this.transit,
  });

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  late final TravelAlarmController _alarmController;
  late final bool _ownsAlarmController;
  _TicketViewMode _viewMode = _TicketViewMode.list;
  String _selectedPayment = 'QRIS';
  String _selectedFilter = 'Semua';
  _TicketItem? _selectedTicket;

  // Matriks QR Code 13x13 tiruan yang realistis dengan pola finder di sudut-sudutnya
  final List<List<int>> _qrMatrix = [
    [1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1],
    [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1],
    [1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1],
    [1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0],
    [1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
    [1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1],
  ];

  @override
  void initState() {
    super.initState();
    _ownsAlarmController = widget.alarmController == null;
    _alarmController = widget.alarmController ?? TravelAlarmController();
    _alarmController.addListener(_handleAlarmChange);
  }

  @override
  void dispose() {
    _alarmController.removeListener(_handleAlarmChange);
    if (_ownsAlarmController) {
      _alarmController.dispose();
    }
    super.dispose();
  }

  void _handleAlarmChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _showAlarmMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _completePayment({
    required String from,
    required String to,
  }) async {
    _alarmController.completePurchase(
      from: from,
      to: to,
      transferStation: widget.transit == '1' ? 'Setiabudi' : null,
    );
    setState(() => _viewMode = _TicketViewMode.active);
    await _openAlarmSetup(from: from, to: to);
  }

  Future<void> _openAlarmSetup({
    required String from,
    required String to,
    String? transferStation,
  }) async {
    final selection = await showTravelAlarmSetupSheet(
      context,
      from: from,
      to: to,
    );
    if (selection == null || !mounted) return;

    if (!_isCurrentAlarmTrip(from, to)) {
      _alarmController.completePurchase(
        from: from,
        to: to,
        transferStation: transferStation,
      );
    }

    _alarmController.configureAlarms(
      departure: selection.departure,
      destination: selection.destination,
    );
    _showAlarmMessage(AppLocalizations.of(context)!.alarmActivated);
  }

  Future<void> _handleAlarmButton(String from, String to) async {
    final controlsCurrentTrip = _isCurrentAlarmTrip(from, to);
    if (!controlsCurrentTrip || !_alarmController.state.hasAnyAlarm) {
      await _openAlarmSetup(
        from: from,
        to: to,
        transferStation: widget.transit == '1' ? 'Setiabudi' : null,
      );
      return;
    }

    final shouldDisable = await showTravelAlarmDisableDialog(
      context,
      departureEnabled: _alarmController.state.departureAlarmEnabled,
      destinationEnabled: _alarmController.state.destinationAlarmEnabled,
    );
    if (!shouldDisable || !mounted) return;

    _alarmController.cancelAllAlarms();
    _showAlarmMessage(AppLocalizations.of(context)!.alarmDeactivated);
  }

  bool _isCurrentAlarmTrip(String from, String to) {
    final activeTrip = _alarmController.state.activeTrip;
    return activeTrip?.from == from && activeTrip?.to == to;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Parameter perjalanan dinamis atau nilai default
    final fromSt = widget.from ?? 'Setiabudi';
    final toSt = widget.to ?? 'Pancoran Bank BJB';
    final fareVal = widget.fare != null ? 'Rp${widget.fare}' : 'Rp7.800';
    final dur = widget.duration ?? '18';
    final isTransit = widget.transit == '1';

    final serviceInfo = isTransit
        ? 'LRT Jabodebek · ${l10n.durationMinutes(dur)} · ${l10n.oneTransitAt('Setiabudi')}'
        : '${l10n.lineNoTransit('LRT Jabodebek')} · ${l10n.durationMinutes(dur)}';
    final tickets = _buildTicketItems(fromSt, toSt, fareVal, serviceInfo);
    final currentTicket = _selectedTicket ?? tickets.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Action Bar (Custom App Bar) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_viewMode != _TicketViewMode.list) {
                        setState(() {
                          _viewMode = _TicketViewMode.list;
                        });
                      } else {
                        context.go('/');
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.actionBack,
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.tickets,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE600), // Alert/A11Y Yellow
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'A11Y',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Body Content ──
            Expanded(
              child: switch (_viewMode) {
                _TicketViewMode.list => _buildTicketListView(tickets),
                _TicketViewMode.checkout => _buildPaymentSelectionView(
                  currentTicket.from,
                  currentTicket.to,
                  currentTicket.fare,
                  currentTicket.serviceInfo,
                ),
                _TicketViewMode.active => _buildActiveTicketView(
                  currentTicket.from,
                  currentTicket.to,
                ),
              },
            ),

            // ── Bottom Navigation Bar ──
            const AppBottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  List<_TicketItem> _buildTicketItems(
    String from,
    String to,
    String fare,
    String serviceInfo,
  ) {
    final activeTrip = _alarmController.state.activeTrip;
    final purchasedTicketIsActive =
        activeTrip?.from == from && activeTrip?.to == to;

    return [
      _TicketItem(
        from: from,
        to: to,
        fare: fare,
        serviceInfo: serviceInfo,
        validityText: purchasedTicketIsActive
            ? AppLocalizations.of(context)!.validUntil
            : AppLocalizations.of(context)!.payBefore,
        status: purchasedTicketIsActive
            ? _TicketStatus.active
            : _TicketStatus.pending,
      ),
      _TicketItem(
        from: 'Manggarai',
        to: 'Tanah Abang',
        fare: 'Rp4.000',
        serviceInfo: '${AppLocalizations.of(context)!.lineNoTransit('KRL Jabodetabek')} · ${AppLocalizations.of(context)!.durationMinutes('6')}',
        validityText: AppLocalizations.of(context)!.validUntil,
        status: _TicketStatus.active,
      ),
      _TicketItem(
        from: 'Halim',
        to: 'Cawang',
        fare: 'Rp4.000',
        serviceInfo: '${AppLocalizations.of(context)!.lineNoTransit('LRT Jabodebek')} · ${AppLocalizations.of(context)!.durationMinutes('8')}',
        validityText: AppLocalizations.of(context)!.validUntil,
        status: _TicketStatus.active,
      ),
      _TicketItem(
        from: 'Dukuh Atas',
        to: 'Setiabudi',
        fare: 'Rp5.000',
        serviceInfo: '${AppLocalizations.of(context)!.lineNoTransit('LRT Jabodebek')} · ${AppLocalizations.of(context)!.durationMinutes('7')}',
        validityText: AppLocalizations.of(context)!.usedToday,
        status: _TicketStatus.completed,
      ),
    ];
  }

  // 1. Tampilan daftar tiket sebelum metode pembayaran
  Widget _buildTicketListView(List<_TicketItem> tickets) {
    final l10n = AppLocalizations.of(context)!;
    final filteredTickets = tickets.where((ticket) {
      if (_selectedFilter == l10n.unpaid) {
        return ticket.status == _TicketStatus.pending;
      }
      if (_selectedFilter == l10n.active) {
        return ticket.status == _TicketStatus.active;
      }
      if (_selectedFilter == l10n.completed) {
        return ticket.status == _TicketStatus.completed;
      }
      return true;
    }).toList();

    final activeCount = tickets
        .where((ticket) => ticket.status == _TicketStatus.active)
        .length;
    final pendingCount = tickets
        .where((ticket) => ticket.status == _TicketStatus.pending)
        .length;
    final completedCount = tickets
        .where((ticket) => ticket.status == _TicketStatus.completed)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.confirmation_num_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.travelTicket,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.ticketStatusSummary(activeCount, pendingCount, completedCount),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [l10n.all, l10n.unpaid, l10n.active, l10n.completed].map((
              filter,
            ) {
              final isSelected = _selectedFilter == filter || (_selectedFilter == 'Semua' && filter == l10n.all);
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.cardBorder,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          ...filteredTickets.map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTicketCard(ticket),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTicketCard(_TicketItem ticket) {
    final l10n = AppLocalizations.of(context)!;
    final isPending = ticket.status == _TicketStatus.pending;
    final isCompleted = ticket.status == _TicketStatus.completed;
    final accentColor = isPending
        ? AppColors.accentOrange
        : isCompleted
        ? AppColors.textSecondary
        : AppColors.statusGreen;
    final statusText = isPending
        ? l10n.notPaid
        : isCompleted
        ? l10n.alreadyUsed
        : l10n.readyToScan;
    final actionText = isPending
        ? l10n.payNow
        : isCompleted
        ? l10n.detail
        : l10n.viewQR;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending
              ? AppColors.accentOrange.withValues(alpha: 0.28)
              : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${ticket.from} -> ${ticket.to}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ticket.serviceInfo,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: 8),
            Text(
              l10n.historyCompleted,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.fare,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ticket.validityText,
                      style: TextStyle(
                        fontSize: 11,
                        color: isPending
                            ? AppColors.a11yBannerText
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  key: Key('ticket-action-${ticket.from}-${ticket.to}'),
                  onPressed: () {
                    if (isCompleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.ticketAlreadyUsed),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _selectedTicket = ticket;
                      _viewMode = isPending
                          ? _TicketViewMode.checkout
                          : _TicketViewMode.active;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPending
                        ? AppColors.buttonOrange
                        : isCompleted
                        ? AppColors.textSecondary
                        : AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Tampilan Layar Checkout
  Widget _buildPaymentSelectionView(
    String from,
    String to,
    String fare,
    String serviceInfo,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Route Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$from ➔ $to',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  serviceInfo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fare,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.qrValidUntil,
                            style: const TextStyle(
                              color: Color(0xFFC2410C),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '23:59',
                            style: TextStyle(
                              color: Color(0xFFC2410C),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Options Title
          Text(
            l10n.choosePayment,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // QRIS Option
          _buildPaymentMethodTile(
            name: 'QRIS',
            desc: l10n.qrisDesc,
            isSelected: _selectedPayment == 'QRIS',
            onTap: () => setState(() => _selectedPayment = 'QRIS'),
          ),
          const SizedBox(height: 12),

          // Credit Card Option
          _buildPaymentMethodTile(
            name: l10n.creditCard,
            desc: 'Visa, Mastercard, GPN',
            isSelected: _selectedPayment == 'Card',
            onTap: () => setState(() => _selectedPayment = 'Card'),
          ),
          const SizedBox(height: 12),

          // VA Option
          _buildPaymentMethodTile(
            name: l10n.virtualAccount,
            desc: l10n.vaDesc,
            isSelected: _selectedPayment == 'VA',
            onTap: () => setState(() => _selectedPayment = 'VA'),
          ),
          const SizedBox(height: 24),

          // HP / Email Input Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.optionalContact,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.optionalContactDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pay CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _completePayment(from: from, to: to),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316), // Accent Orange
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.payAmount(fare),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helper widget untuk ubin metode pembayaran
  Widget _buildPaymentMethodTile({
    required String name,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button icon representation
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. Tampilan Layar Tiket Aktif (Setelah pembayaran berhasil)
  Widget _buildActiveTicketView(String from, String to) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Alert Banner "Pembayaran berhasil"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.paymentSuccess,
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.scanQrAtGate,
                        style: const TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Custom Grid QR Code
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 13,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                  ),
                  itemCount: 13 * 13,
                  itemBuilder: (context, index) {
                    int row = index ~/ 13;
                    int col = index % 13;
                    bool isBlack = _qrMatrix[row][col] == 1;
                    return Container(
                      decoration: BoxDecoration(
                        color: isBlack ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // KAI Metro Access title & Route
              const Text(
                'KAI Metro Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$from ➔ $to',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Info Metadata Grid Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.validGateInBefore,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.today2359,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.withoutAccount,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.guest,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB), // Accent Blue
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save & Share Buttons Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.ticketSaved),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005BAC), // KAI Blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.saveTicket,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.sharingTicketLink),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF005BAC)),
                          foregroundColor: const Color(0xFF005BAC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.share,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // A11Y bottom info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), // Light yellow
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: Text(
                  l10n.a11yQrInfo,
                  style: const TextStyle(
                    color: Color(0xFFB7791F),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 88),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 16,
          child: TravelAlarmButton(
            isActive:
                _isCurrentAlarmTrip(from, to) &&
                _alarmController.state.hasAnyAlarm,
            onPressed: () => _handleAlarmButton(from, to),
          ),
        ),
      ],
    );
  }
}
