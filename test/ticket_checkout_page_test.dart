import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/tickets/domain/entities/ticket.dart';
import 'package:timetable/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:timetable/features/tickets/presentation/controllers/ticket_controller.dart';
import 'package:timetable/features/tickets/presentation/pages/tickets_page.dart';
import 'package:timetable/l10n/app_localizations.dart';

void main() {
  testWidgets('guest history restores and labels the active email', (
    tester,
  ) async {
    final controller = TicketController(_Repository());
    addTearDown(controller.dispose);
    await controller.loadHistory(contactEmail: 'guest@example.com');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: TicketsPage(ticketController: controller, authenticated: false),
      ),
    );
    await tester.pumpAndSettle();

    final emailField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(emailField.controller?.text, 'guest@example.com');
    expect(find.text('Menampilkan tiket untuk'), findsOneWidget);
    expect(find.byKey(const Key('active-history-email')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('active-history-email'))).data,
      'guest@example.com',
    );
    expect(
      find.bySemanticsLabel('Menampilkan tiket untuk guest@example.com'),
      findsOneWidget,
    );
  });

  testWidgets('checkout opens hosted Xendit link and remains pending', (
    tester,
  ) async {
    final controller = TicketController(_Repository());
    Uri? opened;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: TicketsPage(
          ticketController: controller,
          authenticated: true,
          from: 'Setiabudi',
          to: 'Manggarai',
          fare: 'Rp7.800',
          duration: '7',
          transit: '0',
          checkoutLauncher: (uri) async {
            opened = uri;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('buy-ticket-button')));
    await tester.pumpAndSettle();

    expect(opened, Uri.parse('https://checkout.xendit.test/session-1'));
    expect(find.text('Menunggu pembayaran'), findsOneWidget);
    expect(controller.state.stage, TicketStage.checkoutReady);
    expect(find.text('Tiket aktif'), findsNothing);
  });
}

class _Repository implements TicketRepository {
  @override
  Future<Ticket> orderTicket({
    required String origin,
    required String destination,
    required DateTime travelDate,
    int passengerCount = 1,
    String? contactEmail,
  }) async => Ticket(
    id: 'ticket-1',
    publicCode: 'TKT-001',
    origin: const TicketStation(id: 'origin', name: 'Setiabudi'),
    destination: const TicketStation(id: 'destination', name: 'Manggarai'),
    passengerCount: 1,
    unitPrice: 7800,
    price: 7800,
    status: TicketStatus.paymentPending,
    travelDate: travelDate,
    payments: const [],
  );

  @override
  Future<TicketPayment> createCheckout({
    required String ticketId,
    String? contactEmail,
  }) async => TicketPayment(
    id: 'payment-1',
    referenceId: 'reference-1',
    amount: 7800,
    currency: 'IDR',
    status: PaymentStatus.pending,
    checkoutUrl: Uri.parse('https://checkout.xendit.test/session-1'),
  );

  @override
  Future<PaymentSnapshot> getPaymentStatus({
    required String ticketId,
    String? contactEmail,
  }) => throw UnimplementedError();

  @override
  Future<TicketPage> listTickets({String? contactEmail}) async =>
      const TicketPage(items: [], page: 1, limit: 20, total: 0);
}
