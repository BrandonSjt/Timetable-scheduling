import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Data model untuk setiap stasiun di peta skematik
class StationData {
  final String name;
  final Offset relativePosition; // Posisi relatif (0.0 - 1.0) terhadap canvas

  const StationData({required this.name, required this.relativePosition});
}

/// Daftar stasiun yang ditampilkan di peta skematik
const List<StationData> stations = [
  StationData(name: 'Tanah Abang', relativePosition: Offset(0.15, 0.10)),
  StationData(name: 'Manggarai', relativePosition: Offset(0.30, 0.32)),
  StationData(name: 'Setiabudi', relativePosition: Offset(0.46, 0.56)),
  StationData(name: 'Halim', relativePosition: Offset(0.12, 0.64)),
  StationData(name: 'Cawang', relativePosition: Offset(0.85, 0.64)),
];

/// CustomPainter untuk menggambar peta skematik jalur KRL dan LRT
/// Disesuaikan agar mirip desain Figma: garis tipis, kurva halus.
class SchematicMapPainter extends CustomPainter {
  final bool showColors;
  final String? selectedStation;

  SchematicMapPainter({
    this.showColors = false,
    this.selectedStation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Posisi stasiun berdasarkan ukuran canvas ──
    final tanahAbang = Offset(size.width * 0.15, size.height * 0.10);
    final manggarai = Offset(size.width * 0.30, size.height * 0.32);
    final setiabudi = Offset(size.width * 0.46, size.height * 0.56);
    final halim = Offset(size.width * 0.12, size.height * 0.64);
    final cawang = Offset(size.width * 0.85, size.height * 0.64);

    // ── Paint untuk garis LRT (Hijau) ──
    final lrtPaint = Paint()
      ..color = showColors ? AppColors.lineLRT : AppColors.lineLRT.withValues(alpha: 0.20)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ── Paint untuk garis KRL (Oranye) ──
    final krlPaint = Paint()
      ..color = showColors ? AppColors.lineKRL : AppColors.lineKRL.withValues(alpha: 0.20)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ════════════════════════════════════════════════════════
    // JALUR KRL (HIJAU): off-screen atas-kiri → Tanah Abang → Manggarai → Setiabudi → off-screen bawah
    // Garis diagonal lalu melengkung menjadi vertikal ke bawah
    // ════════════════════════════════════════════════════════
    final krlPath = Path()
      // Mulai dari off-screen kiri atas
      ..moveTo(tanahAbang.dx - 40, tanahAbang.dy - 30)
      ..lineTo(tanahAbang.dx, tanahAbang.dy)
      // Tanah Abang → Manggarai: garis diagonal
      ..lineTo(manggarai.dx, manggarai.dy)
      // Manggarai → Setiabudi: kurva halus menjadi vertikal
      ..quadraticBezierTo(
        setiabudi.dx, manggarai.dy + 20,
        setiabudi.dx, setiabudi.dy,
      )
      // Setiabudi → off-screen bawah: garis vertikal lurus ke bawah
      ..lineTo(setiabudi.dx, size.height + 20);
    canvas.drawPath(krlPath, krlPaint);

    // ════════════════════════════════════════════════════════
    // JALUR LRT (ORANYE): off-screen kiri → Halim → Setiabudi → Cawang → off-screen kanan
    // Garis horizontal lalu melengkung naik ke Setiabudi, lalu turun lagi ke Cawang
    // ════════════════════════════════════════════════════════
    final lrtPath = Path()
      // Mulai dari off-screen kiri
      ..moveTo(-10, halim.dy)
      ..lineTo(halim.dx, halim.dy)
      // Halim → Setiabudi: kurva naik dari horizontal ke node Setiabudi
      ..quadraticBezierTo(
        setiabudi.dx - 30, halim.dy,
        setiabudi.dx, setiabudi.dy,
      )
      // Setiabudi → Cawang: kurva turun dari Setiabudi ke horizontal
      ..quadraticBezierTo(
        setiabudi.dx + 30, halim.dy,
        cawang.dx, cawang.dy,
      )
      // Cawang → off-screen kanan
      ..lineTo(size.width + 10, cawang.dy);
    canvas.drawPath(lrtPath, lrtPaint);

    // ── Gambar node stasiun ──
    final stationPositions = {
      'Tanah Abang': tanahAbang,
      'Manggarai': manggarai,
      'Setiabudi': setiabudi,
      'Halim': halim,
      'Cawang': cawang,
    };

    for (final entry in stationPositions.entries) {
      final isSelected = selectedStation != null && entry.key == selectedStation;
      _drawStation(canvas, entry.value, isSelected: isSelected);
    }

    // ── Gambar label stasiun ──
    _drawLabel(canvas, tanahAbang, 'Tanah Abang', dx: 14, dy: -6);
    _drawLabel(canvas, manggarai, 'Manggarai', dx: 14, dy: -6);
    _drawLabel(canvas, setiabudi, 'Setiabudi', dx: 16, dy: -22, isBold: true, fontSize: 16);
    _drawLabel(canvas, halim, 'Halim', dx: -8, dy: 16, alignRight: true);
    _drawLabel(canvas, cawang, 'Cawang', dx: -8, dy: -22, alignRight: true);
  }

  void _drawStation(Canvas canvas, Offset position, {bool isSelected = false}) {
    // White fill
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, isSelected ? 9 : 5, outerPaint);

    // Border
    final borderPaint = Paint()
      ..color = isSelected ? AppColors.textPrimary : AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5;
    canvas.drawCircle(position, isSelected ? 9 : 5, borderPaint);

    // Inner dot for selected
    if (isSelected) {
      final dotPaint = Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, 3, dotPaint);
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset position,
    String text, {
    double dx = 14,
    double dy = -6,
    bool alignRight = false,
    bool isBold = false,
    double fontSize = 13,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    double labelX = position.dx + dx;
    double labelY = position.dy + dy;

    // Untuk label yang di-align ke kanan (Halim, Cawang)
    if (alignRight) {
      labelX = position.dx - textPainter.width + dx;
    }

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(covariant SchematicMapPainter oldDelegate) {
    return oldDelegate.showColors != showColors ||
        oldDelegate.selectedStation != selectedStation;
  }
}
