import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/train_map_page.dart';
import '../../features/search_station/presentation/pages/search_station_page.dart';
import '../../features/route_result/presentation/pages/route_result_page.dart';
import '../../features/timetable/presentation/pages/timetable_page.dart';

/// Konfigurasi routing utama aplikasi menggunakan GoRouter.
/// Semua rute halaman didefinisikan di sini.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Tab Beranda - Peta skematik berwarna + info stasiun terdekat
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    // Tab Kereta - Peta skematik pudar + detail stasiun terpilih
    GoRoute(
      path: '/kereta',
      builder: (context, state) => const TrainMapPage(),
    ),

    // Cari Stasiun - Search + filter + daftar stasiun
    GoRoute(
      path: '/cari-stasiun',
      builder: (context, state) => const SearchStationPage(),
    ),

    // Hasil Rute - Detail rute tercepat + ETA + timeline
    GoRoute(
      path: '/rute',
      builder: (context, state) => const RouteResultPage(),
    ),

    // Timetable - Jadwal keberangkatan (fitur yang sudah ada)
    GoRoute(
      path: '/timetable',
      builder: (context, state) => const TimetablePage(),
    ),
  ],
);
