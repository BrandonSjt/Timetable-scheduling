import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../widgets/station_card.dart';

class _StationItem {
  final String name;
  final String lineInfo;
  final String statusText;
  final Color statusColor;
  final bool isLrt;
  final bool isKrl;
  final bool isMrt;
  final bool isAccessible;

  const _StationItem({
    required this.name,
    required this.lineInfo,
    required this.statusText,
    required this.statusColor,
    required this.isLrt,
    required this.isKrl,
    required this.isMrt,
    required this.isAccessible,
  });
}

const List<_StationItem> _allStations = [
  // ── MRT JAKARTA ──
  _StationItem(name: 'Bundaran HI', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Stasiun Utama · 3 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Dukuh Atas', lineInfo: 'MRT, LRT Jabodebek, & KRL', statusText: 'Transit Utama · 3 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: true, isMrt: true, isAccessible: true),
  _StationItem(name: 'Setiabudi', lineInfo: 'MRT, LRT Jabodebek, & KRL', statusText: 'Transit Aksesibel · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: true, isMrt: true, isAccessible: true),
  _StationItem(name: 'Bendungan Hilir', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Istora Mandiri', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Senayan', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'ASEAN HQ', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 6 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Blok M', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lift & Eskalator', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Blok A', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Haji Nawi', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Cipete Raya', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Fatmawati', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),
  _StationItem(name: 'Lebak Bulus', lineInfo: 'MRT Lin Utara - Selatan', statusText: 'Terminus · 3 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: false, isMrt: true, isAccessible: true),

  // ── KRL BOGOR & NAMBO ──
  _StationItem(name: 'Jakarta Kota', lineInfo: 'KRL Lin Bogor & Tanjung Priok', statusText: 'Transit Terminus · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Jayakarta', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Mangga Besar', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Sawah Besar', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Juanda', lineInfo: 'KRL Lin Bogor', statusText: 'Peron Ramai · 4 menit', statusColor: AppColors.statusAmber, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Gondangdia', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cikini', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Manggarai', lineInfo: 'KRL Lin Bogor & Cikarang', statusText: 'Transit Utama · 3 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tebet', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cawang', lineInfo: 'KRL Lin Bogor & LRT Jabodebek', statusText: 'Transit Aksesibel · 6 menit', statusColor: AppColors.primaryBlue, isLrt: true, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Duren Kalibata', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pasar Minggu Baru', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pasar Minggu', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tanjung Barat', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Lenteng Agung', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Univ. Pancasila', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Univ. Indonesia', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pondok Cina', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Depok Baru', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Depok', lineInfo: 'KRL Lin Bogor', statusText: 'Peron Ramai · 4 menit', statusColor: AppColors.statusAmber, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Citayam', lineInfo: 'KRL Lin Bogor & Cabang Nambo', statusText: 'Transit Cabang · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Bojong Gede', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cilebut', lineInfo: 'KRL Lin Bogor', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Bogor', lineInfo: 'KRL Lin Bogor', statusText: 'Terminus · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pondok Rajeg', lineInfo: 'KRL Cabang Nambo', statusText: 'Lancar · 6 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cibinong', lineInfo: 'KRL Cabang Nambo', statusText: 'Lancar · 7 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Gunung Putri', lineInfo: 'KRL Cabang Nambo', statusText: 'Lancar · 8 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Nambo', lineInfo: 'KRL Cabang Nambo', statusText: 'Terminus Cabang · 8 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),

  // ── KRL CIKARANG ──
  _StationItem(name: 'Cikarang', lineInfo: 'KRL Lin Cikarang Timur', statusText: 'Terminus Timur · 6 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Metland Telagamurni', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cibitung', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 6 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tambun', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Bekasi Timur', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Bekasi', lineInfo: 'KRL Lin Cikarang', statusText: 'Transit Utama · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kranji', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cakung', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Klender Baru', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Buaran', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Klender', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Jatinegara', lineInfo: 'KRL Lin Cikarang Loop & East', statusText: 'Transit Utama · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Matraman', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Sudirman', lineInfo: 'KRL Lin Cikarang & MRT', statusText: 'Transit Sudirman · 3 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: true, isAccessible: true),
  _StationItem(name: 'BNI City', lineInfo: 'KRL Cikarang & Kereta Bandara', statusText: 'Transit Bandara · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Karet', lineInfo: 'KRL Lin Cikarang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tanah Abang', lineInfo: 'KRL Lin Cikarang & Rangkasbitung', statusText: 'Transit Utama · 4 menit', statusColor: AppColors.statusAmber, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Duri', lineInfo: 'KRL Lin Cikarang & Tangerang', statusText: 'Transit Tangerang · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Angke', lineInfo: 'KRL Lin Cikarang Loop', statusText: 'Terminus Loop · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kp. Bandan', lineInfo: 'KRL Lin Cikarang & Priok', statusText: 'Transit Loop Utara · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Rajawali', lineInfo: 'KRL Lin Cikarang Loop', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kemayoran', lineInfo: 'KRL Lin Cikarang Loop', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pasar Senen', lineInfo: 'KRL Lin Cikarang Loop', statusText: 'Stasiun Besar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Gang Sentiong', lineInfo: 'KRL Lin Cikarang Loop', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kramat', lineInfo: 'KRL Lin Cikarang Loop', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pondok Jati', lineInfo: 'KRL Lin Cikarang Loop', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),

  // ── KRL TANGERANG ──
  _StationItem(name: 'Grogol', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pesing', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Taman Kota', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Bojong Indah', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Rawa Buaya', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kalideres', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Poris', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Batu Ceper', lineInfo: 'KRL Lin Tangerang & Airport', statusText: 'Transit Bandara · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tanah Tinggi', lineInfo: 'KRL Lin Tangerang', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tangerang', lineInfo: 'KRL Lin Tangerang', statusText: 'Terminus · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),

  // ── KRL RANGKASBITUNG ──
  _StationItem(name: 'Palmerah', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kebayoran', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pondok Ranji', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Jurangmangu', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Sudimara', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Rawa Buntu', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Serpong', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cisauk', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cicayur', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Parung Panjang', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Stasiun Antara · 6 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cilejit', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 6 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Daru', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 7 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tenjo', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 7 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tigaraksa', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 8 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cikoya', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 8 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Maja', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Stasiun Antara · 8 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Citeras', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Lancar · 9 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Rangkasbitung', lineInfo: 'KRL Lin Rangkasbitung', statusText: 'Terminus Barat · 10 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),

  // ── KRL TANJUNG PRIOK ──
  _StationItem(name: 'Ancol', lineInfo: 'KRL Lin Tanjung Priok', statusText: 'Lancar · 6 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Jakarta Int. Stadium', lineInfo: 'KRL Lin Tanjung Priok', statusText: 'Akses Stadium · 7 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Tanjung Priok', lineInfo: 'KRL Lin Tanjung Priok', statusText: 'Terminus Pelabuhan · 8 menit', statusColor: AppColors.statusGreen, isLrt: false, isKrl: true, isMrt: false, isAccessible: true),

  // ── LRT JABODEBEK ──
  _StationItem(name: 'Halim', lineInfo: 'LRT Jabodebek & KCIC Whoosh', statusText: 'Intermodal KCIC · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Dukuh Atas LRT', lineInfo: 'LRT Jabodebek (Bekasi & Cibubur)', statusText: 'Terminus LRT · 3 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Setiabudi LRT', lineInfo: 'LRT Jabodebek', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Rasuna Said', lineInfo: 'LRT Jabodebek', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kuningan', lineInfo: 'LRT Jabodebek', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pancoran', lineInfo: 'LRT Jabodebek', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cikoko', lineInfo: 'LRT Jabodebek & KRL Cawang', statusText: 'Transit Cawang · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: true, isMrt: false, isAccessible: true),
  _StationItem(name: 'Ciliwung', lineInfo: 'LRT Jabodebek', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Jatibening Baru', lineInfo: 'LRT Jabodebek Lin Bekasi', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cikunir 1', lineInfo: 'LRT Jabodebek Lin Bekasi', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Cikunir 2', lineInfo: 'LRT Jabodebek Lin Bekasi', statusText: 'Lancar · 6 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Bekasi Barat', lineInfo: 'LRT Jabodebek Lin Bekasi', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Jati Mulya', lineInfo: 'LRT Jabodebek Lin Bekasi', statusText: 'Terminus Bekasi · 6 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Taman Mini', lineInfo: 'LRT Jabodebek Lin Cibubur', statusText: 'Lancar · 6 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Kampung Rambutan', lineInfo: 'LRT Jabodebek Lin Cibubur', statusText: 'Transit Terminal · 6 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Ciracas', lineInfo: 'LRT Jabodebek Lin Cibubur', statusText: 'Lancar · 7 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Harjamukti', lineInfo: 'LRT Jabodebek Lin Cibubur', statusText: 'Terminus Cibubur · 7 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),

  // ── LRT JAKARTA ──
  _StationItem(name: 'Pegangsaan Dua', lineInfo: 'LRT Jakarta', statusText: 'Depo & Terminus · 5 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Boulevard Utara', lineInfo: 'LRT Jakarta', statusText: 'Akses Mal Kelapa Gading', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Boulevard Selatan', lineInfo: 'LRT Jakarta', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Pulomas', lineInfo: 'LRT Jakarta', statusText: 'Lancar · 4 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Equestrian', lineInfo: 'LRT Jakarta', statusText: 'Lancar · 5 menit', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
  _StationItem(name: 'Velodrome', lineInfo: 'LRT Jakarta', statusText: 'Terminus Rawamangun', statusColor: AppColors.statusGreen, isLrt: true, isKrl: false, isMrt: false, isAccessible: true),
];

/// Halaman Cari Stasiun (Screen 2 di Figma)
/// Menampilkan search bar, filter layanan, daftar stasiun,
/// dan mendukung pemilihan stasiun secara fungsional.
class SearchStationPage extends StatefulWidget {
  const SearchStationPage({super.key});

  @override
  State<SearchStationPage> createState() => _SearchStationPageState();
}

class _SearchStationPageState extends State<SearchStationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Membaca action dan stasiun asal dari query parameters
    final uri = GoRouterState.of(context).uri;
    final action = uri.queryParameters['action'];
    final fromStation = uri.queryParameters['from'];
    final isSelectingDestination = action == 'select_destination';

    // Logika penyaringan stasiun
    final filteredStations = _allStations.where((station) {
      // 1. Filter stasiun asal agar tidak bisa dipilih sebagai stasiun tujuan
      if (isSelectingDestination && station.name == fromStation) {
        return false;
      }

      // 2. Filter berdasarkan ketikan pencarian
      final matchesSearch = station.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            station.lineInfo.toLowerCase().contains(_searchQuery.toLowerCase());

      // 3. Filter berdasarkan tab layanan
      final matchesFilter = _selectedFilter == 'Semua' ||
                            (_selectedFilter == 'LRT' && station.isLrt) ||
                            (_selectedFilter == 'KRL' && station.isKrl) ||
                            (_selectedFilter == 'MRT' && station.isMrt) ||
                            (_selectedFilter == 'Aksesibel' && station.isAccessible);

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── App Bar Custom ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/'),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              isSelectingDestination
                                  ? 'Pilih stasiun tujuan'
                                  : 'Cari stasiun',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // ── A11Y Button ──
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.a11yYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'A11Y',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isSelectingDestination && fromStation != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                        child: Text(
                          'Mulai perjalanan dari: $fromStation',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                    // ── Search Bar ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Ketik nama stasiun, jalur, atau area',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Filter Layanan ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Filter layanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterChip('Semua'),
                          const SizedBox(width: 8),
                          _buildFilterChip('LRT'),
                          const SizedBox(width: 8),
                          _buildFilterChip('KRL'),
                          const SizedBox(width: 8),
                          _buildFilterChip('MRT'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Aksesibel'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Hasil Cepat ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hasil cepat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Daftar Stasiun Dinamis ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: filteredStations.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'Stasiun tidak ditemukan',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          : Column(
                              children: filteredStations.map((station) {
                                return StationCard(
                                  name: station.name,
                                  lineInfo: station.lineInfo,
                                  statusText: station.statusText,
                                  statusColor: station.statusColor,
                                  onTap: () {
                                    final fromQuery = fromStation != null ? '&from=$fromStation' : '';
                                    context.go('/?selected=${station.name}$fromQuery');
                                  },
                                );
                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // ── Banner Tanpa Login ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.a11yBannerBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanpa login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.a11yBannerText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Favorit dan riwayat disimpan lokal di perangkat.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Navigation Bar ──
            AppBottomNavBar(currentIndex: isSelectingDestination ? 0 : 1),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ServiceFilterChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }
}
