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
