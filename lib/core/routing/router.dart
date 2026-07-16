import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/search_station/presentation/pages/search_station_page.dart';
import '../../features/route_result/presentation/pages/route_result_page.dart';
import '../../features/timetable/presentation/pages/timetable_page.dart';
import '../../features/tickets/presentation/pages/tickets_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/accessibility_page.dart';
import '../../features/home/presentation/pages/departure_detail_page.dart';

/// Konfigurasi routing utama aplikasi menggunakan GoRouter.
/// Semua rute halaman didefinisikan di sini.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Tab Utama (Menggunakan NoTransitionPage agar panel navigasi bawah tidak ikut ter-slide) ──

    // Tab 0: Beranda
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: HomePage(),
      ),
    ),

    // Tab 1: Jadwal (Timetable)
    GoRoute(
      path: '/timetable',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TimetablePage(),
      ),
    ),

    // Tab 2: Tiket Saya - Tiket QR (dengan opsi parameter query)
    GoRoute(
      path: '/tiket',
      pageBuilder: (context, state) {
        final from = state.uri.queryParameters['from'];
        final to = state.uri.queryParameters['to'];
        final fare = state.uri.queryParameters['fare'];
        final duration = state.uri.queryParameters['duration'];
        final transit = state.uri.queryParameters['transit'];
        return NoTransitionPage(
          child: TicketsPage(
            from: from,
            to: to,
            fare: fare,
            duration: duration,
            transit: transit,
          ),
        );
      },
    ),

    // Tab 3: Promo
    GoRoute(
      path: '/promo',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: PromoPage(),
      ),
    ),

    // Tab 4: Akun
    GoRoute(
      path: '/akun',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ProfilePage(),
      ),
    ),

    // Pengaturan Aksesibilitas
    GoRoute(
      path: '/aksesibilitas',
      builder: (context, state) => const AccessibilityPage(),
    ),

    // ── Halaman Detail (Menggunakan transisi bawaan slide standar) ──

    // Cari Stasiun
    GoRoute(
      path: '/cari-stasiun',
      builder: (context, state) => const SearchStationPage(),
    ),

    // Hasil Rute
    GoRoute(
      path: '/rute',
      builder: (context, state) => const RouteResultPage(),
    ),

    // Detail Keberangkatan
    GoRoute(
      path: '/departure-detail',
      builder: (context, state) {
        final lineType = state.uri.queryParameters['lineType'] ?? '';
        final destination = state.uri.queryParameters['destination'] ?? '';
        final duration = state.uri.queryParameters['duration'] ?? '';
        final platform = state.uri.queryParameters['platform'] ?? '';
        return DepartureDetailPage(
          lineType: lineType,
          destination: destination,
          duration: duration,
          platform: platform,
        );
      },
    ),
  ],
);
