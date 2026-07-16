import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ════════════════════════════════════════════════════════════════════
// DATA MODEL
// ════════════════════════════════════════════════════════════════════

/// Data model untuk setiap stasiun di peta skematik
class StationData {
  final String id;           // Unique ID (lowercase, no spaces)
  final String name;         // Display name
  final Offset position;     // Absolute position on canvas (pixels)
  final bool isTransit;      // Apakah stasiun interchange?
  final List<String> lines;  // Line IDs yang melewati stasiun ini

  const StationData({
    required this.id,
    required this.name,
    required this.position,
    this.isTransit = false,
    this.lines = const [],
  });
}

/// Data model untuk satu jalur transit
class LineData {
  final String id;
  final String name;
  final Color color;
  final double strokeWidth;
  final List<String> stationIds; // Ordered station IDs along this line

  const LineData({
    required this.id,
    required this.name,
    required this.color,
    this.strokeWidth = 3.0,
    required this.stationIds,
  });
}

// ════════════════════════════════════════════════════════════════════
// CANVAS CONSTANTS
// ════════════════════════════════════════════════════════════════════

/// Canvas dimensions for the schematic map
const double kMapWidth = 2200.0;
const double kMapHeight = 1800.0;

// ════════════════════════════════════════════════════════════════════
// STATION DATABASE  (~80 unique stations)
// Layout: Schematic grid-based positioning
// Center of map: Manggarai / Dukuh Atas area (~1100, ~900)
// ════════════════════════════════════════════════════════════════════

const List<StationData> stations = [
  // ── KRL BOGOR LINE (Red) ─── North to South along center-left ──
  StationData(id: 'jakarta_kota', name: 'Jakarta Kota', position: Offset(700, 180), isTransit: true, lines: ['bogor', 'tanjung_priok']),
  StationData(id: 'jayakarta', name: 'Jayakarta', position: Offset(700, 240), lines: ['bogor']),
  StationData(id: 'mangga_besar', name: 'Mangga Besar', position: Offset(700, 300), lines: ['bogor']),
  StationData(id: 'sawah_besar', name: 'Sawah Besar', position: Offset(700, 360), lines: ['bogor']),
  StationData(id: 'juanda', name: 'Juanda', position: Offset(700, 420), lines: ['bogor']),
  StationData(id: 'gondangdia', name: 'Gondangdia', position: Offset(700, 480), lines: ['bogor']),
  StationData(id: 'cikini', name: 'Cikini', position: Offset(700, 540), lines: ['bogor']),
  StationData(id: 'manggarai', name: 'Manggarai', position: Offset(700, 650), isTransit: true, lines: ['bogor', 'cikarang']),
  StationData(id: 'tebet', name: 'Tebet', position: Offset(700, 730), lines: ['bogor']),
  StationData(id: 'cawang_krl', name: 'Cawang', position: Offset(700, 810), isTransit: true, lines: ['bogor']),
  StationData(id: 'duren_kalibata', name: 'Duren Kalibata', position: Offset(700, 890), lines: ['bogor']),
  StationData(id: 'pasar_minggu_baru', name: 'Ps. Minggu Baru', position: Offset(700, 950), lines: ['bogor']),
  StationData(id: 'pasar_minggu', name: 'Pasar Minggu', position: Offset(700, 1010), lines: ['bogor']),
  StationData(id: 'tanjung_barat', name: 'Tanjung Barat', position: Offset(700, 1070), lines: ['bogor']),
  StationData(id: 'lenteng_agung', name: 'Lenteng Agung', position: Offset(700, 1130), lines: ['bogor']),
  StationData(id: 'univ_pancasila', name: 'Univ. Pancasila', position: Offset(700, 1190), lines: ['bogor']),
  StationData(id: 'univ_indonesia', name: 'Univ. Indonesia', position: Offset(700, 1250), lines: ['bogor']),
  StationData(id: 'pondok_cina', name: 'Pondok Cina', position: Offset(700, 1310), lines: ['bogor']),
  StationData(id: 'depok_baru', name: 'Depok Baru', position: Offset(700, 1370), lines: ['bogor']),
  StationData(id: 'depok', name: 'Depok', position: Offset(700, 1430), lines: ['bogor']),
  StationData(id: 'citayam', name: 'Citayam', position: Offset(700, 1490), isTransit: true, lines: ['bogor']),
  StationData(id: 'bojong_gede', name: 'Bojong Gede', position: Offset(700, 1550), lines: ['bogor']),
  StationData(id: 'cilebut', name: 'Cilebut', position: Offset(700, 1610), lines: ['bogor']),
  StationData(id: 'bogor', name: 'Bogor', position: Offset(700, 1680), lines: ['bogor']),
  // Cabang Nambo
  StationData(id: 'pondok_rajeg', name: 'Pondok Rajeg', position: Offset(800, 1540), lines: ['bogor_nambo']),
  StationData(id: 'cibinong', name: 'Cibinong', position: Offset(900, 1590), lines: ['bogor_nambo']),
  StationData(id: 'nambo', name: 'Nambo', position: Offset(1000, 1640), lines: ['bogor_nambo']),

  // ── KRL RANGKASBITUNG LINE (Green) ─── Tanah Abang going southwest ──
  // Tanah Abang is shared, defined below in Cikarang loop
  StationData(id: 'palmerah', name: 'Palmerah', position: Offset(430, 730), lines: ['rangkasbitung']),
  StationData(id: 'kebayoran', name: 'Kebayoran', position: Offset(370, 790), lines: ['rangkasbitung']),
  StationData(id: 'pondok_ranji', name: 'Pondok Ranji', position: Offset(310, 850), lines: ['rangkasbitung']),
  StationData(id: 'jurangmangu', name: 'Jurangmangu', position: Offset(250, 910), lines: ['rangkasbitung']),
  StationData(id: 'sudimara', name: 'Sudimara', position: Offset(190, 970), lines: ['rangkasbitung']),
  StationData(id: 'rawa_buntu', name: 'Rawa Buntu', position: Offset(130, 1030), lines: ['rangkasbitung']),
  StationData(id: 'serpong', name: 'Serpong', position: Offset(130, 1100), lines: ['rangkasbitung']),
  StationData(id: 'cisauk', name: 'Cisauk', position: Offset(130, 1160), lines: ['rangkasbitung']),
  StationData(id: 'cicayur', name: 'Cicayur', position: Offset(130, 1220), lines: ['rangkasbitung']),
  StationData(id: 'parung_panjang', name: 'Parung Panjang', position: Offset(130, 1280), lines: ['rangkasbitung']),
  StationData(id: 'cilejit', name: 'Cilejit', position: Offset(130, 1340), lines: ['rangkasbitung']),
  StationData(id: 'daru', name: 'Daru', position: Offset(130, 1400), lines: ['rangkasbitung']),
  StationData(id: 'tenjo', name: 'Tenjo', position: Offset(130, 1460), lines: ['rangkasbitung']),
  StationData(id: 'tigaraksa', name: 'Tigaraksa', position: Offset(130, 1520), lines: ['rangkasbitung']),
  StationData(id: 'cikoya', name: 'Cikoya', position: Offset(130, 1580), lines: ['rangkasbitung']),
  StationData(id: 'maja', name: 'Maja', position: Offset(130, 1640), lines: ['rangkasbitung']),
  StationData(id: 'citeras', name: 'Citeras', position: Offset(130, 1700), lines: ['rangkasbitung']),
  StationData(id: 'rangkasbitung', name: 'Rangkasbitung', position: Offset(130, 1760), lines: ['rangkasbitung']),

  // ── KRL TANGERANG LINE (Brown) ─── Duri going west ──
  // Duri is shared, defined in Cikarang loop
  StationData(id: 'grogol', name: 'Grogol', position: Offset(320, 470), lines: ['tangerang']),
  StationData(id: 'pesing', name: 'Pesing', position: Offset(260, 470), lines: ['tangerang']),
  StationData(id: 'taman_kota', name: 'Taman Kota', position: Offset(200, 470), lines: ['tangerang']),
  StationData(id: 'bojong_indah', name: 'Bojong Indah', position: Offset(140, 470), lines: ['tangerang']),
  StationData(id: 'rawa_buaya', name: 'Rawa Buaya', position: Offset(140, 400), lines: ['tangerang']),
  StationData(id: 'kalideres', name: 'Kalideres', position: Offset(140, 340), lines: ['tangerang']),
  StationData(id: 'poris', name: 'Poris', position: Offset(140, 280), lines: ['tangerang']),
  StationData(id: 'batu_ceper', name: 'Batu Ceper', position: Offset(140, 220), lines: ['tangerang']),
  StationData(id: 'tanah_tinggi', name: 'Tanah Tinggi', position: Offset(140, 160), lines: ['tangerang']),
  StationData(id: 'tangerang', name: 'Tangerang', position: Offset(140, 100), lines: ['tangerang']),

  // ── KRL CIKARANG LINE (Blue) ─── Loop section inside Jakarta ──
  StationData(id: 'kampung_bandan', name: 'Kampung Bandan', position: Offset(580, 180), isTransit: true, lines: ['cikarang', 'tanjung_priok']),
  StationData(id: 'angke', name: 'Angke', position: Offset(460, 300), lines: ['cikarang']),
  StationData(id: 'duri', name: 'Duri', position: Offset(380, 470), isTransit: true, lines: ['cikarang', 'tangerang']),
  StationData(id: 'tanah_abang', name: 'Tanah Abang', position: Offset(490, 660), isTransit: true, lines: ['cikarang', 'rangkasbitung']),
  StationData(id: 'karet', name: 'Karet', position: Offset(580, 660), lines: ['cikarang']),
  StationData(id: 'sudirman', name: 'Sudirman', position: Offset(660, 660), isTransit: true, lines: ['cikarang']),
  // Manggarai already defined above (bogor line) — shared
  // Loop north side: Jatinegara → Pasar Senen → Kampung Bandan
  StationData(id: 'matraman', name: 'Matraman', position: Offset(820, 600), lines: ['cikarang']),
  StationData(id: 'jatinegara', name: 'Jatinegara', position: Offset(940, 540), isTransit: true, lines: ['cikarang']),
  StationData(id: 'pondok_jati', name: 'Pondok Jati', position: Offset(940, 470), lines: ['cikarang']),
  StationData(id: 'kramat', name: 'Kramat', position: Offset(940, 410), lines: ['cikarang']),
  StationData(id: 'gang_sentiong', name: 'Gang Sentiong', position: Offset(940, 350), lines: ['cikarang']),
  StationData(id: 'pasar_senen', name: 'Pasar Senen', position: Offset(940, 290), isTransit: true, lines: ['cikarang']),
  StationData(id: 'kemayoran', name: 'Kemayoran', position: Offset(830, 230), lines: ['cikarang']),
  StationData(id: 'rajawali', name: 'Rajawali', position: Offset(720, 180), lines: ['cikarang']),
  // Cikarang straight section: Jatinegara → east
  StationData(id: 'klender', name: 'Klender', position: Offset(1080, 540), lines: ['cikarang']),
  StationData(id: 'buaran', name: 'Buaran', position: Offset(1160, 540), lines: ['cikarang']),
  StationData(id: 'klender_baru', name: 'Klender Baru', position: Offset(1240, 540), lines: ['cikarang']),
  StationData(id: 'cakung', name: 'Cakung', position: Offset(1320, 540), lines: ['cikarang']),
  StationData(id: 'kranji', name: 'Kranji', position: Offset(1400, 540), lines: ['cikarang']),
  StationData(id: 'bekasi', name: 'Bekasi', position: Offset(1500, 540), isTransit: true, lines: ['cikarang']),
  StationData(id: 'bekasi_timur', name: 'Bekasi Timur', position: Offset(1600, 540), lines: ['cikarang']),
  StationData(id: 'tambun', name: 'Tambun', position: Offset(1700, 540), lines: ['cikarang']),
  StationData(id: 'cibitung', name: 'Cibitung', position: Offset(1800, 540), lines: ['cikarang']),
  StationData(id: 'metland', name: 'Metland Telaga Murni', position: Offset(1900, 540), lines: ['cikarang']),
  StationData(id: 'cikarang', name: 'Cikarang', position: Offset(2020, 540), lines: ['cikarang']),

  // ── KRL TANJUNG PRIOK LINE (Pink) ─── Jakarta Kota going north ──
  // Jakarta Kota & Kampung Bandan shared
  StationData(id: 'ancol', name: 'Ancol', position: Offset(580, 120), lines: ['tanjung_priok']),
  StationData(id: 'jis', name: 'JIS', position: Offset(580, 70), lines: ['tanjung_priok']),
  StationData(id: 'tanjung_priok', name: 'Tanjung Priok', position: Offset(680, 70), lines: ['tanjung_priok']),

  // ── MRT UTARA-SELATAN (Dark Blue) ─── Vertical line on left-center ──
  StationData(id: 'bundaran_hi', name: 'Bundaran HI', position: Offset(530, 560), isTransit: true, lines: ['mrt']),
  StationData(id: 'dukuh_atas', name: 'Dukuh Atas', position: Offset(530, 630), isTransit: true, lines: ['mrt', 'lrt_jabodebek']),
  StationData(id: 'setiabudi', name: 'Setiabudi', position: Offset(530, 700), isTransit: true, lines: ['mrt', 'lrt_jabodebek']),
  StationData(id: 'bendungan_hilir', name: 'Bendungan Hilir', position: Offset(530, 770), lines: ['mrt']),
  StationData(id: 'istora', name: 'Istora Mandiri', position: Offset(530, 840), lines: ['mrt']),
  StationData(id: 'senayan', name: 'Senayan', position: Offset(530, 910), lines: ['mrt']),
  StationData(id: 'asean', name: 'ASEAN', position: Offset(530, 980), lines: ['mrt']),
  StationData(id: 'blok_m', name: 'Blok M BCA', position: Offset(530, 1050), isTransit: true, lines: ['mrt']),
  StationData(id: 'blok_a', name: 'Blok A', position: Offset(530, 1120), lines: ['mrt']),
  StationData(id: 'haji_nawi', name: 'Haji Nawi', position: Offset(530, 1190), lines: ['mrt']),
  StationData(id: 'cipete_raya', name: 'Cipete Raya', position: Offset(530, 1260), lines: ['mrt']),
  StationData(id: 'fatmawati', name: 'Fatmawati', position: Offset(530, 1330), lines: ['mrt']),
  StationData(id: 'lebak_bulus', name: 'Lebak Bulus', position: Offset(530, 1410), lines: ['mrt']),

  // ── LRT JABODEBEK Batang Utama (Orange) ─── Dukuh Atas → Cawang ──
  // Dukuh Atas & Setiabudi shared with MRT
  StationData(id: 'rasuna_said', name: 'Rasuna Said', position: Offset(640, 770), lines: ['lrt_jabodebek']),
  StationData(id: 'kuningan', name: 'Kuningan', position: Offset(750, 840), lines: ['lrt_jabodebek']),
  StationData(id: 'pancoran', name: 'Pancoran', position: Offset(860, 910), lines: ['lrt_jabodebek']),
  StationData(id: 'cikoko', name: 'Cikoko', position: Offset(970, 910), lines: ['lrt_jabodebek']),
  StationData(id: 'ciliwung', name: 'Ciliwung', position: Offset(1080, 910), lines: ['lrt_jabodebek']),
  StationData(id: 'cawang_lrt', name: 'Cawang', position: Offset(1190, 910), isTransit: true, lines: ['lrt_jabodebek', 'lrt_bekasi', 'lrt_cibubur']),

  // ── LRT JABODEBEK Lin Bekasi (Orange) ─── Cawang → east ──
  StationData(id: 'halim', name: 'Halim', position: Offset(1310, 910), lines: ['lrt_bekasi']),
  StationData(id: 'jatibening_baru', name: 'Jatibening Baru', position: Offset(1430, 910), lines: ['lrt_bekasi']),
  StationData(id: 'cikunir_1', name: 'Cikunir I', position: Offset(1550, 910), lines: ['lrt_bekasi']),
  StationData(id: 'cikunir_2', name: 'Cikunir II', position: Offset(1670, 910), lines: ['lrt_bekasi']),
  StationData(id: 'bekasi_barat', name: 'Bekasi Barat', position: Offset(1790, 910), lines: ['lrt_bekasi']),
  StationData(id: 'jatimulya', name: 'Jatimulya', position: Offset(1920, 910), lines: ['lrt_bekasi']),

  // ── LRT JABODEBEK Lin Cibubur (Light Orange) ─── Cawang → southeast ──
  StationData(id: 'taman_mini', name: 'Taman Mini', position: Offset(1260, 1010), lines: ['lrt_cibubur']),
  StationData(id: 'kampung_rambutan', name: 'Kp. Rambutan', position: Offset(1330, 1110), lines: ['lrt_cibubur']),
  StationData(id: 'ciracas', name: 'Ciracas', position: Offset(1400, 1210), lines: ['lrt_cibubur']),
  StationData(id: 'harjamukti', name: 'Harjamukti', position: Offset(1470, 1310), lines: ['lrt_cibubur']),

  // ── LRT JAKARTA (Light Green) ─── Northeast area ──
  StationData(id: 'pegangsaan_dua', name: 'Pegangsaan Dua', position: Offset(1350, 120), lines: ['lrt_jakarta']),
  StationData(id: 'boulevard_utara', name: 'Boulevard Utara', position: Offset(1350, 180), lines: ['lrt_jakarta']),
  StationData(id: 'boulevard_selatan', name: 'Boulevard Selatan', position: Offset(1350, 240), lines: ['lrt_jakarta']),
  StationData(id: 'pulomas', name: 'Pulomas', position: Offset(1350, 300), lines: ['lrt_jakarta']),
  StationData(id: 'equestrian', name: 'Equestrian', position: Offset(1350, 360), lines: ['lrt_jakarta']),
  StationData(id: 'velodrome', name: 'Velodrome', position: Offset(1350, 420), lines: ['lrt_jakarta']),
];

// ════════════════════════════════════════════════════════════════════
// LINE DATABASE (10 lines)
// ════════════════════════════════════════════════════════════════════

const List<LineData> transitLines = [
  // ── KRL Lines ──
  LineData(
    id: 'bogor',
    name: 'KRL Bogor',
    color: AppColors.lineBogor,
    stationIds: [
      'jakarta_kota', 'jayakarta', 'mangga_besar', 'sawah_besar', 'juanda',
      'gondangdia', 'cikini', 'manggarai', 'tebet', 'cawang_krl',
      'duren_kalibata', 'pasar_minggu_baru', 'pasar_minggu', 'tanjung_barat',
      'lenteng_agung', 'univ_pancasila', 'univ_indonesia', 'pondok_cina',
      'depok_baru', 'depok', 'citayam', 'bojong_gede', 'cilebut', 'bogor',
    ],
  ),
  LineData(
    id: 'bogor_nambo',
    name: 'KRL Nambo',
    color: AppColors.lineBogor,
    strokeWidth: 2.5,
    stationIds: ['citayam', 'pondok_rajeg', 'cibinong', 'nambo'],
  ),
  LineData(
    id: 'rangkasbitung',
    name: 'KRL Rangkasbitung',
    color: AppColors.lineRangkasbitung,
    stationIds: [
      'tanah_abang', 'palmerah', 'kebayoran', 'pondok_ranji', 'jurangmangu',
      'sudimara', 'rawa_buntu', 'serpong', 'cisauk', 'cicayur',
      'parung_panjang', 'cilejit', 'daru', 'tenjo', 'tigaraksa', 'cikoya',
      'maja', 'citeras', 'rangkasbitung',
    ],
  ),
  LineData(
    id: 'tangerang',
    name: 'KRL Tangerang',
    color: AppColors.lineTangerang,
    stationIds: [
      'duri', 'grogol', 'pesing', 'taman_kota', 'bojong_indah',
      'rawa_buaya', 'kalideres', 'poris', 'batu_ceper', 'tanah_tinggi',
      'tangerang',
    ],
  ),
  // Cikarang loop — south side (Kampung Bandan → ... → Manggarai)
  LineData(
    id: 'cikarang_south',
    name: 'KRL Cikarang (via Manggarai)',
    color: AppColors.lineCikarang,
    stationIds: [
      'kampung_bandan', 'angke', 'duri', 'tanah_abang', 'karet',
      'sudirman', 'manggarai',
    ],
  ),
  // Cikarang loop — north side (Manggarai → Jatinegara → ... → Kampung Bandan)
  LineData(
    id: 'cikarang_north',
    name: 'KRL Cikarang (via Ps. Senen)',
    color: AppColors.lineCikarang,
    stationIds: [
      'manggarai', 'matraman', 'jatinegara', 'pondok_jati', 'kramat',
      'gang_sentiong', 'pasar_senen', 'kemayoran', 'rajawali', 'kampung_bandan',
    ],
  ),
  // Cikarang straight — Jatinegara → Cikarang
  LineData(
    id: 'cikarang_east',
    name: 'KRL Cikarang (Timur)',
    color: AppColors.lineCikarang,
    stationIds: [
      'jatinegara', 'klender', 'buaran', 'klender_baru', 'cakung',
      'kranji', 'bekasi', 'bekasi_timur', 'tambun', 'cibitung',
      'metland', 'cikarang',
    ],
  ),
  LineData(
    id: 'tanjung_priok',
    name: 'KRL Tanjung Priok',
    color: AppColors.lineTanjungPriok,
    stationIds: [
      'jakarta_kota', 'kampung_bandan', 'ancol', 'jis', 'tanjung_priok',
    ],
  ),
  // ── MRT ──
  LineData(
    id: 'mrt',
    name: 'MRT Jakarta',
    color: AppColors.lineMRT,
    stationIds: [
      'bundaran_hi', 'dukuh_atas', 'setiabudi', 'bendungan_hilir',
      'istora', 'senayan', 'asean', 'blok_m', 'blok_a', 'haji_nawi',
      'cipete_raya', 'fatmawati', 'lebak_bulus',
    ],
  ),
  // ── LRT Jabodebek ──
  LineData(
    id: 'lrt_jabodebek',
    name: 'LRT Jabodebek',
    color: AppColors.lineLRT,
    stationIds: [
      'dukuh_atas', 'setiabudi', 'rasuna_said', 'kuningan', 'pancoran',
      'cikoko', 'ciliwung', 'cawang_lrt',
    ],
  ),
  LineData(
    id: 'lrt_bekasi',
    name: 'LRT Bekasi',
    color: AppColors.lineLRT,
    stationIds: [
      'cawang_lrt', 'halim', 'jatibening_baru', 'cikunir_1', 'cikunir_2',
      'bekasi_barat', 'jatimulya',
    ],
  ),
  LineData(
    id: 'lrt_cibubur',
    name: 'LRT Cibubur',
    color: AppColors.lineLRTCibubur,
    stationIds: [
      'cawang_lrt', 'taman_mini', 'kampung_rambutan', 'ciracas', 'harjamukti',
    ],
  ),
  // ── LRT Jakarta ──
  LineData(
    id: 'lrt_jakarta',
    name: 'LRT Jakarta',
    color: AppColors.lineLRTJakarta,
    stationIds: [
      'pegangsaan_dua', 'boulevard_utara', 'boulevard_selatan',
      'pulomas', 'equestrian', 'velodrome',
    ],
  ),
];

// ════════════════════════════════════════════════════════════════════
// MAP PAINTER
// ════════════════════════════════════════════════════════════════════

/// Helper to look up a station by id
StationData? _findStation(String id) {
  for (final s in stations) {
    if (s.id == id) return s;
  }
  return null;
}

/// CustomPainter untuk menggambar peta skematik jalur KRL, MRT, dan LRT
/// Garis lurus saja (horizontal, vertikal, diagonal) — TIDAK ADA kurva.
enum LabelPos { top, bottom, left, right }
class SchematicMapPainter extends CustomPainter {
  final bool showColors;
  final String? selectedStation;
  final String? fromStation;
  final Set<String>? visibleLineIds; // null = show all

  SchematicMapPainter({
    this.showColors = false,
    this.selectedStation,
    this.fromStation,
    this.visibleLineIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Draw all lines ──
    for (final line in transitLines) {
      final bool isVisible = visibleLineIds == null || visibleLineIds!.contains(line.id);
      final paint = Paint()
        ..color = isVisible
            ? (showColors ? line.color : line.color.withValues(alpha: 0.85))
            : line.color.withValues(alpha: 0.12)
        ..strokeWidth = line.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      bool first = true;
      for (final stationId in line.stationIds) {
        final station = _findStation(stationId);
        if (station == null) continue;
        if (first) {
          path.moveTo(station.position.dx, station.position.dy);
          first = false;
        } else {
          path.lineTo(station.position.dx, station.position.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    // ── Draw stations ──
    for (final station in stations) {
      final isSelected = selectedStation == station.id || selectedStation == station.name;
      final isFrom = fromStation == station.id || fromStation == station.name;

      // Check if station belongs to any visible line
      bool stationVisible = true;
      if (visibleLineIds != null) {
        stationVisible = transitLines.any((line) =>
          visibleLineIds!.contains(line.id) &&
          line.stationIds.contains(station.id));
      }

      _drawStation(canvas, station, isSelected: isSelected, isFrom: isFrom, isVisible: stationVisible);
    }

    // ── Draw labels ──
    for (final station in stations) {
      bool stationVisible = true;
      if (visibleLineIds != null) {
        stationVisible = transitLines.any((line) =>
          visibleLineIds!.contains(line.id) &&
          line.stationIds.contains(station.id));
      }
      if (!stationVisible) continue;
      _drawLabel(canvas, station);
    }
  }

  void _drawStation(Canvas canvas, StationData station, {
    bool isSelected = false,
    bool isFrom = false,
    bool isVisible = true,
  }) {
    if (!isVisible) return;

    // Highlight "Dari" station with a larger glowing circle
    if (isFrom) {
      final highlightPaint = Paint()
        ..color = AppColors.primaryBlue.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(station.position, 18, highlightPaint);

      final highlightBorder = Paint()
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(station.position, 18, highlightBorder);
    }

    final double radius = station.isTransit ? 7 : 4;
    final double selectedRadius = isSelected || isFrom ? 10 : radius;

    // White fill
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(station.position, selectedRadius, outerPaint);

    // Border
    final borderPaint = Paint()
      ..color = isSelected || isFrom
          ? AppColors.textPrimary
          : (station.isTransit ? AppColors.textPrimary : AppColors.textSecondary)
      ..style = PaintingStyle.stroke
      ..strokeWidth = station.isTransit ? 2.5 : 1.5;
    canvas.drawCircle(station.position, selectedRadius, borderPaint);

    // Inner dot for transit or selected
    if (station.isTransit || isSelected || isFrom) {
      final dotPaint = Paint()
        ..color = isFrom ? AppColors.primaryBlue : AppColors.textPrimary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(station.position, isSelected || isFrom ? 3 : 2, dotPaint);
    }
  }

  LabelPos _getLabelPos(StationData station) {
    final id = station.id;
    // Stasiun transit utama (titik pertemuan banyak garis)
    if (['manggarai', 'dukuh_atas', 'kampung_bandan', 'jatinegara', 'jakarta_kota'].contains(id)) return LabelPos.top;
    if (['tanah_abang', 'cawang_krl', 'cawang_lrt'].contains(id)) return LabelPos.bottom;
    
    // Jalur Horizontal LRT (Pancoran, Cikoko, Ciliwung, Halim, dsb di y=910)
    // Kecuali MRT Senayan yang juga kebetulan di y=910 (tapi jalurnya vertikal)
    if (station.position.dy == 910 && !station.lines.contains('mrt')) return LabelPos.top;
    
    // Jalur Horizontal Lainnya (Label ditaruh di atas/bawah agar tidak menabrak garis)
    if (station.position.dy == 660 && station.lines.contains('cikarang')) return LabelPos.bottom; // Karet, Sudirman
    if (['grogol', 'pesing', 'taman_kota', 'bojong_indah'].contains(id)) return LabelPos.bottom;
    if (station.position.dy == 540 && station.position.dx > 900) return LabelPos.bottom; // Cikarang East
    if (['tanjung_priok', 'jis', 'rajawali'].contains(id)) return LabelPos.bottom; // Horizontal/diagonal tail
    
    // Jalur Diagonal (Cikarang Loop & LRT)
    if (['matraman', 'kemayoran'].contains(id)) return LabelPos.bottom;
    if (['rasuna_said', 'kuningan'].contains(id)) return LabelPos.left;
    if (station.lines.contains('lrt_cibubur') && id != 'cawang_lrt') return LabelPos.bottom;
    
    // Jalur Vertikal (Label ditaruh di kiri/kanan)
    if (station.lines.contains('mrt')) return LabelPos.left; // Taruh di kiri agar tidak menabrak Bogor Line
    
    // Default untuk jalur vertikal lainnya
    return LabelPos.right;
  }

  void _drawLabel(Canvas canvas, StationData station) {
    final isSelected = selectedStation == station.id || selectedStation == station.name;
    final isFrom = fromStation == station.id || fromStation == station.name;
    final bool isBold = station.isTransit || isSelected || isFrom;
    final double fontSize = station.isTransit ? 11 : 9;

    final textSpan = TextSpan(
      text: station.name,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    double labelX = 0;
    double labelY = 0;
    final pos = _getLabelPos(station);
    final offset = station.isTransit ? 14.0 : 10.0;

    switch (pos) {
      case LabelPos.top:
        labelX = station.position.dx - (textPainter.width / 2);
        labelY = station.position.dy - textPainter.height - offset;
        break;
      case LabelPos.bottom:
        labelX = station.position.dx - (textPainter.width / 2);
        labelY = station.position.dy + offset;
        break;
      case LabelPos.left:
        labelX = station.position.dx - textPainter.width - offset;
        labelY = station.position.dy - (textPainter.height / 2);
        break;
      case LabelPos.right:
        labelX = station.position.dx + offset;
        labelY = station.position.dy - (textPainter.height / 2);
        break;
    }

    textPainter.paint(canvas, Offset(labelX, labelY));
  }



  @override
  bool shouldRepaint(covariant SchematicMapPainter oldDelegate) {
    return oldDelegate.showColors != showColors ||
        oldDelegate.selectedStation != selectedStation ||
        oldDelegate.fromStation != fromStation ||
        oldDelegate.visibleLineIds != visibleLineIds;
  }
}
