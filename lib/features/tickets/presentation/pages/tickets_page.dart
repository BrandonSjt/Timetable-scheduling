import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/widgets/auth_scope.dart';
import '../../../travel_alarm/presentation/controllers/travel_alarm_controller.dart';
import '../../../travel_alarm/presentation/widgets/travel_alarm_button.dart';
import '../../../travel_alarm/presentation/widgets/travel_alarm_setup_sheet.dart';
import '../../domain/entities/ticket.dart';
import '../controllers/ticket_controller.dart';
import '../widgets/ticket_scope.dart';

typedef CheckoutLauncher = Future<bool> Function(Uri uri);

enum _TicketFilter { all, unpaid, active, completed }

class TicketsPage extends StatefulWidget {
  const TicketsPage({
    super.key,
    this.alarmController,
    this.ticketController,
    this.checkoutLauncher,
    this.authenticated,
    this.from,
    this.to,
    this.fare,
    this.duration,
    this.transit,
  });

  final TravelAlarmController? alarmController;
  final TicketController? ticketController;
  final CheckoutLauncher? checkoutLauncher;
  final bool? authenticated;
  final String? from;
  final String? to;
  final String? fare;
  final String? duration;
  final String? transit;

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> with WidgetsBindingObserver {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _emailFormKey = GlobalKey<FormState>();
  late final TravelAlarmController _alarmController;
  late final bool _ownsAlarmController;
  TicketController? _ticketController;
  bool _initialized = false;
  bool _isAuthenticated = false;
  String? _accountEmail;
  bool _checkoutLaunched = false;
  bool _alarmPrepared = false;
  _TicketFilter _filter = _TicketFilter.all;

  TicketController get controller => _ticketController!;
  bool get hasDraft => widget.from != null && widget.to != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsAlarmController = widget.alarmController == null;
    _alarmController = widget.alarmController ?? TravelAlarmController();
    _alarmController.addListener(_redraw);
    if (widget.ticketController != null) {
      _attachController(widget.ticketController!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authScope = context.getInheritedWidgetOfExactType<AuthScope>();
    _isAuthenticated =
        widget.authenticated ?? authScope?.notifier?.isAuthenticated ?? false;
    _accountEmail = authScope?.notifier?.user?.email;
    _attachController(
      widget.ticketController ?? TicketScope.of(context, listen: false),
    );
    _syncGuestEmailField();
    if (!_initialized) {
      _initialized = true;
      if (_isAuthenticated) {
        controller.loadHistory();
      }
    }
  }

  void _attachController(TicketController value) {
    if (identical(_ticketController, value)) return;
    _ticketController?.removeListener(_handleTicketState);
    _ticketController = value..addListener(_handleTicketState);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _checkoutLaunched) {
      controller.checkPayment();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticketController?.removeListener(_handleTicketState);
    _alarmController.removeListener(_redraw);
    if (_ownsAlarmController) _alarmController.dispose();
    _emailFocusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  void _handleTicketState() {
    if (!mounted) return;
    _syncGuestEmailField();
    setState(() {});
    final state = controller.state;
    if (state.stage == TicketStage.checkoutReady && !_checkoutLaunched) {
      _checkoutLaunched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openCheckout());
    }
    if (state.stage == TicketStage.ticketActive && !_alarmPrepared) {
      _alarmPrepared = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _prepareAlarm());
    }
  }

  void _syncGuestEmailField() {
    if (_isAuthenticated || _emailFocusNode.hasFocus) return;
    final email = controller.state.contactEmail?.trim();
    if (email == null || email.isEmpty || email == _emailController.text) {
      return;
    }
    _emailController.value = TextEditingValue(
      text: email,
      selection: TextSelection.collapsed(offset: email.length),
    );
  }

  String? _activeHistoryEmail(TicketViewState state) {
    final value = (_isAuthenticated ? _accountEmail : state.contactEmail)
        ?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> _buyTicket() async {
    if (!_isAuthenticated &&
        !(_emailFormKey.currentState?.validate() ?? false)) {
      return;
    }
    _checkoutLaunched = false;
    _alarmPrepared = false;
    await controller.startCheckout(
      origin: widget.from ?? 'Setiabudi',
      destination: widget.to ?? 'Manggarai',
      travelDate: DateTime.now(),
      contactEmail: _isAuthenticated ? null : _emailController.text.trim(),
    );
  }

  Future<void> _loadGuestHistory() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    await controller.loadHistory(contactEmail: _emailController.text.trim());
  }

  Future<void> _openCheckout() async {
    final uri = controller.state.payment?.checkoutUrl;
    if (uri == null) {
      _message('Tautan pembayaran belum tersedia.');
      return;
    }
    final opened =
        await (widget.checkoutLauncher?.call(uri) ??
            launchUrl(uri, mode: LaunchMode.externalApplication));
    if (!opened && mounted) {
      _message('Halaman pembayaran tidak dapat dibuka.');
    }
  }

  Future<void> _prepareAlarm() async {
    final ticket = controller.state.selectedTicket;
    if (ticket == null || !mounted) return;
    final from = ticket.origin.name;
    final to = ticket.destination.name;
    _alarmController.completePurchase(
      from: from,
      to: to,
      transferStation: widget.transit == '1' ? 'Setiabudi' : null,
    );
    final selection = await showTravelAlarmSetupSheet(
      context,
      from: from,
      to: to,
    );
    if (selection == null || !mounted) return;
    _alarmController.configureAlarms(
      departure: selection.departure,
      destination: selection.destination,
    );
    _message(AppLocalizations.of(context)!.alarmActivated);
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tiket'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: state.stage == TicketStage.ticketActive
            ? _buildActiveTicket(state.selectedTicket!)
            : _buildTicketList(state),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildTicketList(TicketViewState state) {
    final activeEmail = _activeHistoryEmail(state);
    return RefreshIndicator(
      onRefresh: () => controller.loadHistory(
        contactEmail: _isAuthenticated ? null : _emailController.text.trim(),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (hasDraft) _buildTripDraft(),
          if (!_isAuthenticated) ...[
            const SizedBox(height: 12),
            Form(
              key: _emailFormKey,
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Email untuk tiket dan riwayat',
                  hintText: 'nama@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: hasDraft
                      ? null
                      : IconButton(
                          tooltip: 'Tampilkan riwayat',
                          onPressed: _loadGuestHistory,
                          icon: const Icon(Icons.search_rounded),
                        ),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
            ),
          ],
          if (activeEmail != null) ...[
            const SizedBox(height: 10),
            _ActiveEmailContext(email: activeEmail),
          ],
          if (hasDraft) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('buy-ticket-button'),
              onPressed: state.stage == TicketStage.ordering
                  ? null
                  : _buyTicket,
              icon: state.stage == TicketStage.ordering
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.open_in_browser_rounded),
              label: Text(
                state.stage == TicketStage.ordering
                    ? 'Menyiapkan pembayaran'
                    : 'Bayar di Xendit',
              ),
            ),
          ],
          if (state.stage == TicketStage.checkoutReady ||
              state.stage == TicketStage.paymentPending ||
              state.stage == TicketStage.checkingPayment ||
              state.stage == TicketStage.terminal) ...[
            const SizedBox(height: 16),
            _buildPaymentPanel(state),
          ],
          if (state.stage == TicketStage.failure) ...[
            const SizedBox(height: 16),
            _ErrorPanel(
              message: state.errorMessage ?? 'Terjadi kesalahan.',
              onRetry: hasDraft ? _buyTicket : _loadGuestHistory,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tiket saya',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang tiket',
                onPressed: state.stage == TicketStage.loadingHistory
                    ? null
                    : () => controller.loadHistory(
                        contactEmail: _isAuthenticated
                            ? null
                            : _emailController.text.trim(),
                      ),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_TicketFilter>(
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              segments: const [
                ButtonSegment(value: _TicketFilter.all, label: Text('Semua')),
                ButtonSegment(
                  value: _TicketFilter.unpaid,
                  label: Text('Belum bayar'),
                ),
                ButtonSegment(
                  value: _TicketFilter.active,
                  label: Text('Aktif'),
                ),
                ButtonSegment(
                  value: _TicketFilter.completed,
                  label: Text('Selesai'),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (value) =>
                  setState(() => _filter = value.first),
              showSelectedIcon: false,
            ),
          ),
          const SizedBox(height: 12),
          if (state.stage == TicketStage.loadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ..._filteredTickets(state.tickets).map(_buildTicketCard),
          if (state.stage != TicketStage.loadingHistory &&
              _filteredTickets(state.tickets).isEmpty)
            const _EmptyTickets(),
        ],
      ),
    );
  }

  Widget _buildTripDraft() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route_rounded, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text(
                'Perjalanan dipilih',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.from}  →  ${widget.to}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (widget.duration != null) '${widget.duration} menit',
              if (widget.transit != null)
                widget.transit == '1' ? '1 transit' : 'Tanpa transit',
            ].join(' · '),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (widget.fare != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.fare!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentPanel(TicketViewState state) {
    final terminal = state.stage == TicketStage.terminal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(
        color: terminal ? const Color(0xFFFFF1F2) : const Color(0xFFEFF6FF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                terminal ? Icons.error_outline_rounded : Icons.schedule_rounded,
                color: terminal ? AppColors.statusRed : AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  terminal ? 'Pembayaran tidak selesai' : 'Menunggu pembayaran',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tiket aktif hanya setelah Xendit mengonfirmasi pembayaran ke server.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: terminal ? null : _openCheckout,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Buka pembayaran'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.stage == TicketStage.checkingPayment
                      ? null
                      : controller.checkPayment,
                  icon: state.stage == TicketStage.checkingPayment
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_rounded),
                  label: const Text('Cek status'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Ticket> _filteredTickets(List<Ticket> tickets) => switch (_filter) {
    _TicketFilter.all => tickets,
    _TicketFilter.unpaid =>
      tickets.where((ticket) => ticket.isPending).toList(),
    _TicketFilter.active => tickets.where((ticket) => ticket.isActive).toList(),
    _TicketFilter.completed =>
      tickets.where((ticket) => ticket.isCompleted).toList(),
  };

  Widget _buildTicketCard(Ticket ticket) {
    final color = _statusColor(ticket.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            controller.selectTicket(ticket);
            if (ticket.isPending) {
              _checkoutLaunched = true;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${ticket.origin.name}  →  ${ticket.destination.name}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(ticket.status),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${ticket.publicCode} · ${DateFormat('dd MMM yyyy', 'id').format(ticket.travelDate.toLocal())}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(ticket.price),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTicket(Ticket ticket) {
    final from = ticket.origin.name;
    final to = ticket.destination.name;
    final alarmActive = _alarmController.state.hasAnyAlarm;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Kembali ke daftar tiket',
              onPressed: () => controller.loadHistory(
                contactEmail: _isAuthenticated ? null : ticket.contactEmail,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Expanded(
              child: Text(
                'Tiket aktif',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            TravelAlarmButton(isActive: alarmActive, onPressed: _prepareAlarm),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 156,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tunjukkan kode ini di gerbang',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              Text(
                '$from  →  $to',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ticket.publicCode,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (ticket.departureTime != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Berangkat ${ticket.departureTime}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(color: const Color(0xFFF0FDF4)),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.statusGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alarmActive
                      ? _alarmController.nextAlarmDescription
                      : 'Alarm perjalanan belum diaktifkan',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration({Color color = AppColors.surface}) =>
      BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      );

  Color _statusColor(TicketStatus status) => switch (status) {
    TicketStatus.active => AppColors.statusGreen,
    TicketStatus.used => AppColors.textSecondary,
    TicketStatus.expired || TicketStatus.cancelled => AppColors.statusRed,
    _ => AppColors.statusAmber,
  };

  String _statusLabel(TicketStatus status) => switch (status) {
    TicketStatus.pending || TicketStatus.paymentPending => 'Belum dibayar',
    TicketStatus.paid => 'Dibayar',
    TicketStatus.active => 'Aktif',
    TicketStatus.used => 'Sudah digunakan',
    TicketStatus.expired => 'Kedaluwarsa',
    TicketStatus.cancelled => 'Dibatalkan',
    TicketStatus.unknown => 'Tidak diketahui',
  };
}

class _ActiveEmailContext extends StatelessWidget {
  const _ActiveEmailContext({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Menampilkan tiket untuk $email',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlueLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 20,
                  color: AppColors.primaryBlueDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menampilkan tiket untuk',
                      style: TextStyle(
                        color: AppColors.primaryBlueDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      key: const Key('active-history-email'),
                      softWrap: true,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.confirmation_num_outlined,
            size: 44,
            color: AppColors.textHint,
          ),
          SizedBox(height: 10),
          Text('Belum ada tiket pada kategori ini.'),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.statusRed),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
