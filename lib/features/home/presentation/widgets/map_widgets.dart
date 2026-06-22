import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/schematic_map_painter.dart';

/// Widget peta skematik jalur kereta yang bisa di-zoom, di-geser,
/// dan klik stasiun untuk memilihnya.
class MapView extends StatefulWidget {
  final bool showColors;
  final String? selectedStation;
  final ValueChanged<String>? onStationSelected;

  const MapView({
    super.key,
    this.showColors = false,
    this.selectedStation,
    this.onStationSelected,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Mendeteksi stasiun mana yang diklik berdasarkan posisi tap.
  /// Posisi tap dikoreksi menggunakan inverse matrix agar akurat saat di-zoom.
  void _handleTap(TapUpDetails details, Size canvasSize) {
    // Konversi posisi tap dari layar ke koordinat canvas (memperhitungkan zoom/pan)
    final matrix = _transformController.value;
    final inverseMatrix = Matrix4.inverted(matrix);
    final localTap = MatrixUtils.transformPoint(inverseMatrix, details.localPosition);

    // Cek jarak tap ke setiap stasiun (threshold 30px di koordinat canvas)
    for (final station in stations) {
      final stationPos = Offset(
        canvasSize.width * station.relativePosition.dx,
        canvasSize.height * station.relativePosition.dy,
      );
      final distance = (localTap - stationPos).distance;
      if (distance < 30) {
        widget.onStationSelected?.call(station.name);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double mapHeight = 360;
        final canvasSize = Size(constraints.maxWidth, mapHeight);

        return SizedBox(
          width: double.infinity,
          height: mapHeight,
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.8,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(60),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) => _handleTap(details, canvasSize),
              child: CustomPaint(
                size: canvasSize,
                painter: SchematicMapPainter(
                  showColors: widget.showColors,
                  selectedStation: widget.selectedStation,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


/// Chip kecil untuk menampilkan info transit (LRT/KRL + waktu tempuh)
class TransitChip extends StatelessWidget {
  final String lineType;
  final String destination;
  final String duration;
  final Color lineColor;

  const TransitChip({
    super.key,
    required this.lineType,
    required this.destination,
    required this.duration,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: lineColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                lineType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                destination,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tombol aksi stasiun: Dari, Lewat, Ke, Info
class StationActionBar extends StatelessWidget {
  const StationActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.buttonDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(label: 'Dari', onTap: () {}),
          _ActionButton(label: 'Lewat', onTap: () {}),
          _ActionButton(label: 'Ke', onTap: () {}),
          _ActionButton(label: 'Info', onTap: () {}),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Filter chip untuk LRT Jabodebek, KRL Jabodetabek, Kontras
class LineFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback? onTap;

  const LineFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.buttonDark
              : isSelected
                  ? AppColors.primaryBlue
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.buttonDark
                : AppColors.primaryBlue,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: (isDark || isSelected) ? Colors.white : AppColors.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
