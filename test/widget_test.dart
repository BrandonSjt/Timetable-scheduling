import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timetable/core/routing/router.dart';
import 'package:timetable/main.dart';

void main() {
  testWidgets('Home screen renders merged route search entry points', (
    WidgetTester tester,
  ) async {
    appRouter.go('/');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Cari stasiun LRT atau KRL'), findsOneWidget);
    expect(find.text('LRT Jabodebek'), findsOneWidget);
    expect(find.text('KRL Jabodetabek'), findsOneWidget);
    expect(
      find.text(
        'A11Y: Ada daftar rute dan tombol bacakan, peta bukan satu-satunya navigasi.',
      ),
      findsNothing,
    );
  });

  testWidgets('Selected station panel shows next train arrival board', (
    WidgetTester tester,
  ) async {
    appRouter.go('/?selected=Setiabudi');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Kereta berikutnya dari Setiabudi'), findsOneWidget);
    expect(find.text('Datang 3 menit lagi'), findsOneWidget);
    expect(find.text('Perjalanan 7 menit'), findsOneWidget);
    expect(find.text('Peron 1'), findsOneWidget);
  });

  testWidgets('Account opens interactive accessibility settings', (
    WidgetTester tester,
  ) async {
    appRouter.go('/akun');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Aksesibilitas'),
      180,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Aksesibilitas'));
    await tester.pumpAndSettle();

    expect(find.text('Pengaturan tampilan'), findsOneWidget);
    expect(find.text('Kontras, teks, dan suara'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(4));

    var switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.map((item) => item.value), [true, false, true, false]);

    await tester.tap(find.text('Teks besar'));
    await tester.pumpAndSettle();
    switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[1].value, isTrue);

    await tester.scrollUntilVisible(
      find.text('Baca'),
      180,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Baca'));
    await tester.pump();
    expect(
      find.text(
        'Membacakan: Dukuh Atas ke Harjamukti, Peron 2, tiba 4 menit lagi.',
      ),
      findsOneWidget,
    );
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Mode tamu aktif'), findsOneWidget);
  });

  testWidgets('Account opens filterable ticket history without bottom nav', (
    WidgetTester tester,
  ) async {
    appRouter.go('/akun');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Riwayat tiket lokal'),
      180,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Riwayat tiket lokal'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat tiket'), findsOneWidget);
    expect(find.text('Tiket terakhir'), findsOneWidget);
    expect(find.text('Bogor → Jakarta Kota'), findsOneWidget);
    expect(find.text('Dukuh Atas → Harjamukti'), findsOneWidget);
    expect(find.text('Home'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Aktif'));
    await tester.pumpAndSettle();
    expect(find.text('Bogor → Jakarta Kota'), findsOneWidget);
    expect(find.text('Dukuh Atas → Harjamukti'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Mode tamu aktif'), findsOneWidget);
  });

  testWidgets('Ticket tab shows ticket list before payment methods', (
    WidgetTester tester,
  ) async {
    appRouter.go('/tiket');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Tiket'), findsWidgets);
    expect(find.text('Beli tiket tanpa login'), findsNothing);
    expect(find.text('Belum dibayar'), findsWidgets);
    expect(find.text('Bayar sekarang'), findsOneWidget);
    expect(find.text('Lihat QR'), findsWidgets);
    expect(find.text('Pilih pembayaran'), findsNothing);

    await tester.tap(find.text('Bayar sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih pembayaran'), findsOneWidget);
    expect(find.text('QRIS'), findsOneWidget);
  });

  testWidgets('Ticket tab can filter completed ticket history', (
    WidgetTester tester,
  ) async {
    appRouter.go('/tiket');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Selesai'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat selesai'), findsOneWidget);
    expect(find.text('Dukuh Atas -> Setiabudi'), findsOneWidget);
    expect(find.text('Sudah digunakan'), findsOneWidget);
    expect(find.text('Bayar sekarang'), findsNothing);
  });
}
