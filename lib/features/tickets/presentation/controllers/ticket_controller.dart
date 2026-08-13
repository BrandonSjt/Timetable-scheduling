import 'package:flutter/foundation.dart';

import '../../data/datasources/ticket_remote_data_source.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';

enum TicketStage {
  idle,
  loadingHistory,
  historyReady,
  ordering,
  checkoutReady,
  checkingPayment,
  paymentPending,
  ticketActive,
  terminal,
  failure,
}

@immutable
class TicketViewState {
  const TicketViewState({
    this.stage = TicketStage.idle,
    this.tickets = const [],
    this.selectedTicket,
    this.payment,
    this.contactEmail,
    this.errorCode,
    this.errorMessage,
  });

  final TicketStage stage;
  final List<Ticket> tickets;
  final Ticket? selectedTicket;
  final TicketPayment? payment;
  final String? contactEmail;
  final String? errorCode;
  final String? errorMessage;

  TicketViewState copyWith({
    TicketStage? stage,
    List<Ticket>? tickets,
    Ticket? selectedTicket,
    TicketPayment? payment,
    String? contactEmail,
    String? errorCode,
    String? errorMessage,
    bool clearError = false,
  }) => TicketViewState(
    stage: stage ?? this.stage,
    tickets: tickets ?? this.tickets,
    selectedTicket: selectedTicket ?? this.selectedTicket,
    payment: payment ?? this.payment,
    contactEmail: contactEmail ?? this.contactEmail,
    errorCode: clearError ? null : errorCode ?? this.errorCode,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class TicketController extends ChangeNotifier {
  TicketController(this._repository);

  final TicketRepository _repository;
  TicketViewState _state = const TicketViewState();

  TicketViewState get state => _state;

  Future<void> loadHistory({String? contactEmail}) async {
    _setState(
      _state.copyWith(
        stage: TicketStage.loadingHistory,
        contactEmail: contactEmail,
        clearError: true,
      ),
    );
    try {
      final page = await _repository.listTickets(contactEmail: contactEmail);
      _setState(
        _state.copyWith(stage: TicketStage.historyReady, tickets: page.items),
      );
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> startCheckout({
    required String origin,
    required String destination,
    required DateTime travelDate,
    int passengerCount = 1,
    String? contactEmail,
  }) async {
    _setState(
      _state.copyWith(
        stage: TicketStage.ordering,
        contactEmail: contactEmail,
        clearError: true,
      ),
    );
    try {
      final ticket = await _repository.orderTicket(
        origin: origin,
        destination: destination,
        travelDate: travelDate,
        passengerCount: passengerCount,
        contactEmail: contactEmail,
      );
      final payment = await _repository.createCheckout(
        ticketId: ticket.id,
        contactEmail: contactEmail,
      );
      _setState(
        _state.copyWith(
          stage: TicketStage.checkoutReady,
          selectedTicket: ticket,
          payment: payment,
        ),
      );
    } catch (error) {
      _fail(error);
    }
  }

  Future<void> checkPayment() async {
    final ticket = _state.selectedTicket;
    if (ticket == null) return;
    _setState(
      _state.copyWith(stage: TicketStage.checkingPayment, clearError: true),
    );
    try {
      final snapshot = await _repository.getPaymentStatus(
        ticketId: ticket.id,
        contactEmail: _state.contactEmail,
      );
      if (snapshot.ticketStatus == TicketStatus.active ||
          snapshot.ticketStatus == TicketStatus.paid) {
        final page = await _repository.listTickets(
          contactEmail: _state.contactEmail,
        );
        final refreshed = page.items.where((item) => item.id == ticket.id);
        _setState(
          _state.copyWith(
            stage: TicketStage.ticketActive,
            tickets: page.items,
            selectedTicket: refreshed.isEmpty ? ticket : refreshed.first,
            payment: snapshot.payment,
          ),
        );
        return;
      }
      if (snapshot.ticketStatus == TicketStatus.expired ||
          snapshot.ticketStatus == TicketStatus.cancelled ||
          snapshot.payment?.status == PaymentStatus.failed ||
          snapshot.payment?.status == PaymentStatus.expired) {
        _setState(
          _state.copyWith(
            stage: TicketStage.terminal,
            payment: snapshot.payment,
          ),
        );
        return;
      }
      _setState(
        _state.copyWith(
          stage: TicketStage.paymentPending,
          payment: snapshot.payment,
        ),
      );
    } catch (error) {
      _fail(error);
    }
  }

  void selectTicket(Ticket ticket) {
    _setState(
      _state.copyWith(
        selectedTicket: ticket,
        payment: ticket.latestPayment,
        stage: ticket.isActive
            ? TicketStage.ticketActive
            : TicketStage.historyReady,
        contactEmail: ticket.contactEmail,
        clearError: true,
      ),
    );
  }

  void _fail(Object error) {
    if (error is TicketRemoteException) {
      _setState(
        _state.copyWith(
          stage: TicketStage.failure,
          errorCode: error.code,
          errorMessage: error.message,
        ),
      );
      return;
    }
    _setState(
      _state.copyWith(
        stage: TicketStage.failure,
        errorCode: 'UNEXPECTED_ERROR',
        errorMessage: 'Unexpected ticket error',
      ),
    );
  }

  void _setState(TicketViewState value) {
    _state = value;
    notifyListeners();
  }
}
