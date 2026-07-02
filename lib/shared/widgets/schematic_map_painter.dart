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
  StationData(name: 'Bundaran HI', relativePosition: Offset(0.46, 0.20)),
  StationData(name: 'Manggarai', relativePosition: Offset(0.30, 0.32)),
  StationData(name: 'Setiabudi', relativePosition: Offset(0.46, 0.56)),
  StationData(name: 'Halim', relativePosition: Offset(0.12, 0.64)),
  StationData(name: 'Cawang', relativePosition: Offset(0.85, 0.64)),
  StationData(name: 'Blok M', relativePosition: Offset(0.46, 0.85)),
];

/// CustomPainter untuk menggambar peta skematik jalur KRL dan LRT
/// Disesuaikan agar mirip desain Figma: garis tipis, kurva halus.
class SchematicMapPainter extends CustomPainter {
  final bool showColors;
  final String? selectedStation;
  final String? fromStation;

  SchematicMapPainter({
    this.showColors = false,
    this.selectedStation,
    this.fromStation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Posisi stasiun berdasarkan ukuran canvas ──
    final tanahAbang = Offset(size.width * 0.15, size.height * 0.10);
    final bundaranHI = Offset(size.width * 0.46, size.height * 0.20);
    final manggarai = Offset(size.width * 0.30, size.height * 0.32);
    final setiabudi = Offset(size.width * 0.46, size.height * 0.56);
    final halim = Offset(size.width * 0.12, size.height * 0.64);
    final cawang = Offset(size.width * 0.85, size.height * 0.64);
    final blokM = Offset(size.width * 0.46, size.height * 0.85);

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

    // ── Paint untuk garis MRT (Biru) ──
    final mrtPaint = Paint()
      ..color = showColors ? AppColors.lineMRT : AppColors.lineMRT.withValues(alpha: 0.20)
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

    // ════════════════════════════════════════════════════════
    // JALUR MRT (BIRU): Vertikal lurus dari atas ke bawah (Bundaran HI -> Setiabudi -> Blok M)
    // ════════════════════════════════════════════════════════
    final mrtPath = Path()
      ..moveTo(bundaranHI.dx, -20)
      ..lineTo(bundaranHI.dx, bundaranHI.dy)
      ..lineTo(setiabudi.dx, setiabudi.dy)
      ..lineTo(blokM.dx, blokM.dy)
      ..lineTo(blokM.dx, size.height + 20);
    canvas.drawPath(mrtPath, mrtPaint);

    // ── Gambar node stasiun ──
    final stationPositions = {
      'Tanah Abang': tanahAbang,
      'Bundaran HI': bundaranHI,
      'Manggarai': manggarai,
      'Setiabudi': setiabudi,
      'Halim': halim,
      'Cawang': cawang,
      'Blok M': blokM,
    };

    for (final entry in stationPositions.entries) {
      final isSelected = selectedStation != null && entry.key == selectedStation;
      final isFrom = fromStation != null && entry.key == fromStation;
      _drawStation(canvas, entry.value, isSelected: isSelected, isFrom: isFrom);
    }

    // ── Gambar label stasiun ──
    _drawLabel(canvas, tanahAbang, 'Tanah Abang', dx: 14, dy: -6);
    _drawLabel(canvas, bundaranHI, 'Bundaran HI', dx: 14, dy: -6);
    _drawLabel(canvas, manggarai, 'Manggarai', dx: 14, dy: -6);
    _drawLabel(canvas, setiabudi, 'Setiabudi (Transit MRT/LRT/KRL)', dx: 16, dy: -22, isBold: true, fontSize: 13);
    _drawLabel(canvas, halim, 'Halim', dx: -8, dy: 16, alignRight: true);
    _drawLabel(canvas, cawang, 'Cawang', dx: -8, dy: -22, alignRight: true);
    _drawLabel(canvas, blokM, 'Blok M', dx: 14, dy: -6);
  }

  void _drawStation(Canvas canvas, Offset position, {bool isSelected = false, bool isFrom = false}) {
    // Highlight "Dari" station with a larger glowing circle
    if (isFrom) {
      final highlightPaint = Paint()
        ..color = AppColors.primaryBlue.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, 16, highlightPaint);

      final highlightBorder = Paint()
        ..color = AppColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(position, 16, highlightBorder);
    }

    // White fill
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, isSelected || isFrom ? 9 : 5, outerPaint);

    // Border
    final borderPaint = Paint()
      ..color = isSelected || isFrom ? AppColors.textPrimary : AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected || isFrom ? 2.5 : 1.5;
    canvas.drawCircle(position, isSelected || isFrom ? 9 : 5, borderPaint);

    // Inner dot for selected or from
    if (isSelected || isFrom) {
      final dotPaint = Paint()
        ..color = isFrom ? AppColors.primaryBlue : AppColors.textPrimary
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
        oldDelegate.selectedStation != selectedStation ||
        oldDelegate.fromStation != fromStation;
  }
}
