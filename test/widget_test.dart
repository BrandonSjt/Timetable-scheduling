import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timetable/core/routing/router.dart';
import 'package:timetable/core/theme/app_colors.dart';
import 'package:timetable/features/assistant/presentation/controllers/assistant_controller.dart';
import 'package:timetable/features/assistant/presentation/pages/assistant_page.dart';
import 'package:timetable/features/tickets/presentation/pages/tickets_page.dart';
import 'package:timetable/features/travel_alarm/presentation/widgets/travel_alarm_scope.dart';
import 'package:timetable/main.dart';

void main() {
  testWidgets('Tickets and Assistant share one travel alarm controller', (
    WidgetTester tester,
  ) async {
    appRouter.go('/tiket');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final ticketContext = tester.element(find.byType(TicketsPage));
    final ticketController = TravelAlarmScope.of(ticketContext);

    appRouter.go('/asisten');
    await tester.pumpAndSettle();
    final assistantContext = tester.element(find.byType(AssistantPage));

    expect(TravelAlarmScope.of(assistantContext), same(ticketController));
  });

  testWidgets('Home screen renders merged route search entry points', (
    WidgetTester tester,
  ) async {
    appRouter.go('/');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Cari stasiun LRT atau KRL'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump();
    expect(find.text('Filter map akan segera hadir!'), findsOneWidget);
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
    expect(find.text('Perjalanan 5 menit'), findsOneWidget);
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

  testWidgets('Account opens language page and updates its preview', (
    WidgetTester tester,
  ) async {
    appRouter.go('/akun');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Bahasa'),
      180,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Bahasa'));
    await tester.pumpAndSettle();

    expect(find.text('Bahasa aplikasi'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Mode tamu aktif'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Guest mode active'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Terapkan bahasa'),
      180,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Terapkan bahasa'));
    await tester.pump();
    expect(find.text('English applied.'), findsOneWidget);
  });

  testWidgets('Active history opens active ticket detail without bottom nav', (
    WidgetTester tester,
  ) async {
    appRouter.go('/riwayat-tiket');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Aktif'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detail tiket aktif'), findsOneWidget);
    expect(find.text('Kode tiket aktif'), findsOneWidget);
    expect(find.text('Home'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Tiket aktif'),
      180,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Tiket aktif'), findsOneWidget);
    expect(find.textContaining('lokal'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Bagikan kode'),
      120,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Bagikan kode'));
    await tester.pump();
    expect(find.text('Kode tiket aktif siap dibagikan.'), findsOneWidget);
  });

  testWidgets('Account opens searchable help center without bottom nav', (
    WidgetTester tester,
  ) async {
    appRouter.go('/akun');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Pusat Bantuan'),
      180,
      scrollable: find.byType(Scrollable),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pusat Bantuan'));
    await tester.pumpAndSettle();

    expect(find.text('Aksi cepat'), findsOneWidget);
    expect(find.text('Chat petugas'), findsOneWidget);
    expect(find.text('Home'), findsNothing);

    await tester.enterText(find.byType(TextField), 'jadwal');
    await tester.pumpAndSettle();
    expect(find.text('Jadwal atau ETA tidak sesuai'), findsOneWidget);
    expect(find.text('Masalah pembayaran'), findsNothing);

    await tester.tap(find.text('Chat petugas'));
    await tester.pump();
    expect(find.text('Menghubungkan ke chat petugas.'), findsOneWidget);
  });

  testWidgets('Completed history opens completed ticket detail and actions', (
    WidgetTester tester,
  ) async {
    appRouter.go('/riwayat-tiket');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detail tiket selesai'), findsOneWidget);
    expect(find.text('Ringkasan perjalanan'), findsOneWidget);
    expect(find.text('Durasi 44 menit'), findsOneWidget);
    expect(find.text('Home'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Unduh bukti'),
      180,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Unduh bukti'));
    await tester.pump();
    expect(find.text('Bukti perjalanan berhasil disiapkan.'), findsOneWidget);

    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laporkan masalah'));
    await tester.pumpAndSettle();
    expect(find.text('Pusat Bantuan'), findsOneWidget);
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

  testWidgets('Assistant page exposes accessible voice-first controls', (
    WidgetTester tester,
  ) async {
    final controller = AssistantController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: AssistantPage(controller: controller)),
    );

    expect(find.text('Asisten Perjalanan'), findsOneWidget);
    expect(find.text('Dengarkan "Halo Asisten"'), findsOneWidget);
    expect(find.bySemanticsLabel('Mulai percakapan suara'), findsOneWidget);
    expect(find.text('Rencanakan perjalanan'), findsOneWidget);
    expect(find.text('Bantuan petugas'), findsOneWidget);

    final microphoneSemantics = tester
        .getSemantics(find.bySemanticsLabel('Mulai percakapan suara'))
        .getSemanticsData();
    final wakeWordSemantics = tester
        .getSemantics(
          find.bySemanticsLabel(RegExp('Mode kata pemicu Halo Asisten')),
        )
        .getSemanticsData();
    final quickActionSemantics = tester
        .getSemantics(find.bySemanticsLabel('Buka Rencanakan perjalanan'))
        .getSemanticsData();
    expect(microphoneSemantics.hasAction(SemanticsAction.tap), isTrue);
    expect(wakeWordSemantics.hasAction(SemanticsAction.tap), isTrue);
    expect(quickActionSemantics.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.byKey(const Key('wake-word-switch')));
    await tester.pump();

    expect(find.text('Kata pemicu aktif'), findsOneWidget);
    final activeWakeWordText = tester.widget<Text>(
      find.text('Kata pemicu aktif'),
    );
    expect(activeWakeWordText.style?.color, AppColors.textPrimary);
  });

  testWidgets('Assistant page simulates a trip and requests confirmation', (
    WidgetTester tester,
  ) async {
    final controller = AssistantController(
      listeningDuration: const Duration(milliseconds: 1),
      processingDuration: const Duration(milliseconds: 1),
      speakingDuration: const Duration(milliseconds: 1),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: AssistantPage(controller: controller)),
    );

    await tester.tap(find.byKey(const Key('assistant-microphone-button')));
    await tester.pump();
    expect(find.text('Mendengarkan'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 2));

    expect(
      find.text('Saya ingin ke Manggarai dari Setiabudi.'),
      findsOneWidget,
    );
    expect(
      find.text('Rute tercepat membutuhkan 7 menit. Kereta tiba 5 menit lagi.'),
      findsOneWidget,
    );
    expect(find.text('Pakai rute ini'), findsOneWidget);
    expect(find.text('Ulangi'), findsOneWidget);
    expect(find.text('Batalkan'), findsOneWidget);
  });

  testWidgets('Assistant navigation replaces Promo and opens the new tab', (
    WidgetTester tester,
  ) async {
    appRouter.go('/');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Asisten'), findsOneWidget);
    expect(find.text('Promo'), findsNothing);

    await tester.tap(find.text('Asisten'));
    await tester.pumpAndSettle();

    expect(find.text('Asisten Perjalanan'), findsOneWidget);
    final assistantTabSemantics = tester
        .getSemantics(find.bySemanticsLabel('Asisten'))
        .getSemanticsData();
    expect(assistantTabSemantics.hasAction(SemanticsAction.tap), isTrue);
    expect(assistantTabSemantics.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('Assistant navigation redirects the legacy Promo route', (
    WidgetTester tester,
  ) async {
    appRouter.go('/promo');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(appRouter.routeInformationProvider.value.uri.path, '/asisten');
    expect(find.text('Asisten Perjalanan'), findsOneWidget);
  });

  testWidgets('Assistant confirmation opens the requested Manggarai route', (
    WidgetTester tester,
  ) async {
    appRouter.go('/asisten');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final microphoneButton = find.byKey(
      const Key('assistant-microphone-button'),
    );
    await tester.ensureVisible(microphoneButton);
    await tester.tap(microphoneButton);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.ensureVisible(find.text('Pakai rute ini'));
    await tester.tap(find.text('Pakai rute ini'));
    await tester.pumpAndSettle();

    final uri = appRouter.routeInformationProvider.value.uri;
    expect(uri.path, '/rute');
    expect(uri.queryParameters['from'], 'Setiabudi');
    expect(uri.queryParameters['to'], 'Manggarai');
  });

  testWidgets('Assistant quick actions open existing app destinations', (
    WidgetTester tester,
  ) async {
    const destinations = <String, String>{
      'Rencanakan perjalanan': '/cari-stasiun',
      'Kereta berikutnya': '/timetable',
      'Tiket saya': '/tiket',
      'Bantuan petugas': '/pusat-bantuan',
    };

    for (final entry in destinations.entries) {
      appRouter.go('/asisten');
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(entry.key));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(
        appRouter.routeInformationProvider.value.uri.path,
        entry.value,
        reason: '${entry.key} should open ${entry.value}',
      );
    }
  });

  testWidgets('Assistant wake-word mode resets after leaving the page', (
    WidgetTester tester,
  ) async {
    appRouter.go('/asisten');
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('wake-word-switch')));
    await tester.pump();
    expect(find.text('Kata pemicu aktif'), findsOneWidget);

    appRouter.go('/');
    await tester.pumpAndSettle();
    appRouter.go('/asisten');
    await tester.pumpAndSettle();

    expect(find.text('Aktif hanya di halaman ini'), findsOneWidget);
    expect(find.text('Kata pemicu aktif'), findsNothing);
  });

  testWidgets('Assistant page cancels an injected controller when disposed', (
    WidgetTester tester,
  ) async {
    final controller = AssistantController(
      listeningDuration: const Duration(milliseconds: 1),
      processingDuration: const Duration(milliseconds: 1),
      speakingDuration: const Duration(milliseconds: 1),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: AssistantPage(controller: controller)),
    );

    controller.startConversation();
    await tester.pump();
    expect(controller.state, AssistantInteractionState.listening);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 20));

    expect(controller.state, AssistantInteractionState.ready);
    expect(controller.userTranscript, isNull);
    expect(controller.assistantResponse, isNull);
  });

  testWidgets('Assistant page supports 200 percent text scaling', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AssistantController(
      listeningDuration: const Duration(milliseconds: 1),
      processingDuration: const Duration(milliseconds: 1),
      speakingDuration: const Duration(milliseconds: 1),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: AssistantPage(controller: controller),
      ),
    );
    expect(tester.takeException(), isNull);

    final microphoneButton = find.byKey(
      const Key('assistant-microphone-button'),
    );
    await tester.ensureVisible(microphoneButton);
    await tester.tap(microphoneButton);
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 2));

    expect(find.text('Pakai rute ini'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
