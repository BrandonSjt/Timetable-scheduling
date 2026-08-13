import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/tickets/domain/entities/ticket.dart';
import 'package:timetable/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:timetable/features/tickets/presentation/controllers/ticket_controller.dart';

void main() {
  test('order creates hosted checkout and remembers guest ownership', () async {
    final repository = _Repository();
    final controller = TicketController(repository);

    await controller.startCheckout(
      origin: 'Setiabudi',
      destination: 'Manggarai',
      travelDate: DateTime.utc(2026, 8, 13),
      contactEmail: 'guest@example.com',
    );

    expect(controller.state.stage, TicketStage.checkoutReady);
    expect(controller.state.selectedTicket?.id, 'ticket-1');
    expect(
      controller.state.payment?.checkoutUrl.toString(),
      'https://pay.test/1',
    );
    expect(repository.contactEmail, 'guest@example.com');
  });

  test('completed webhook status reloads active server ticket', () async {
    final repository = _Repository()..activeOnStatus = true;
    final controller = TicketController(repository);
    await controller.startCheckout(
      origin: 'Setiabudi',
      destination: 'Manggarai',
      travelDate: DateTime.utc(2026, 8, 13),
      contactEmail: 'guest@example.com',
    );

    await controller.checkPayment();

    expect(controller.state.stage, TicketStage.ticketActive);
    expect(controller.state.selectedTicket?.status, TicketStatus.active);
  });

  test('pending payment remains pending without activating ticket', () async {
    final controller = TicketController(_Repository());
    await controller.startCheckout(
      origin: 'Setiabudi',
      destination: 'Manggarai',
      travelDate: DateTime.utc(2026, 8, 13),
      contactEmail: 'guest@example.com',
    );

    await controller.checkPayment();

    expect(controller.state.stage, TicketStage.paymentPending);
    expect(
      controller.state.selectedTicket?.status,
      TicketStatus.paymentPending,
    );
  });
}

class _Repository implements TicketRepository {
  bool activeOnStatus = false;
  String? contactEmail;

  @override
  Future<Ticket> orderTicket({
    required String origin,
    required String destination,
    required DateTime travelDate,
    int passengerCount = 1,
    String? contactEmail,
  }) async {
    this.contactEmail = contactEmail;
    return _ticket(TicketStatus.paymentPending);
  }

  @override
  Future<TicketPayment> createCheckout({
    required String ticketId,
    String? contactEmail,
  }) async => _payment;

  @override
  Future<PaymentSnapshot> getPaymentStatus({
    required String ticketId,
    String? contactEmail,
  }) async => PaymentSnapshot(
    ticketStatus: activeOnStatus
        ? TicketStatus.active
        : TicketStatus.paymentPending,
    payment: _payment,
  );

  @override
  Future<TicketPage> listTickets({String? contactEmail}) async => TicketPage(
    items: [
      _ticket(
        activeOnStatus ? TicketStatus.active : TicketStatus.paymentPending,
      ),
    ],
    page: 1,
    limit: 20,
    total: 1,
  );
}

Ticket _ticket(TicketStatus status) => Ticket(
  id: 'ticket-1',
  publicCode: 'TKT-001',
  origin: const TicketStation(id: 'origin', name: 'Setiabudi'),
  destination: const TicketStation(id: 'destination', name: 'Manggarai'),
  passengerCount: 1,
  unitPrice: 7800,
  price: 7800,
  status: status,
  travelDate: DateTime.utc(2026, 8, 13),
  payments: [_payment],
  qrCode: status == TicketStatus.active ? 'signed-qr' : null,
);

final _payment = TicketPayment(
  id: 'payment-1',
  referenceId: 'ref-1',
  amount: 7800,
  currency: 'IDR',
  status: PaymentStatus.pending,
  checkoutUrl: Uri.parse('https://pay.test/1'),
);
