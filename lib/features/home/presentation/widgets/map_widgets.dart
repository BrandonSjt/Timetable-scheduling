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

class _MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();

  // ── State untuk deteksi tap manual via Listener ──
  // Listener menangkap raw pointer events SEBELUM gesture arena,
  // sehingga tidak terblokir oleh InteractiveViewer.
  Offset? _pointerDownPos;
  DateTime? _pointerDownTime;

  // RenderBox key untuk mendapatkan posisi lokal relatif terhadap InteractiveViewer
  final GlobalKey _viewerKey = GlobalKey();

  // ── State untuk Animasi Kamera / Viewport ──
  late AnimationController _animationController;
  Animation<Matrix4>? _animationMatrix;
  String? _prevSelectedStation;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(() {
        if (_animationMatrix != null) {
          _transformController.value = _animationMatrix!.value;
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  /// Dipanggil saat pointer turun (sebelum gesture arena memutuskan pan vs tap)
  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPos = event.position; // posisi global
    _pointerDownTime = DateTime.now();
  }

  /// Dipanggil saat pointer naik. Cek apakah ini "tap":
  /// - Jarak geser < 18 logical pixels (toleransi jari)
  /// - Durasi tekan < 300ms
  void _onPointerUp(PointerUpEvent event, Size canvasSize) {
    if (_pointerDownPos == null || _pointerDownTime == null) return;

    final distance = (event.position - _pointerDownPos!).distance;
    final duration = DateTime.now().difference(_pointerDownTime!);

    // Threshold: gerakan kecil + durasi pendek = ini tap, bukan pan
    if (distance < 18 && duration.inMilliseconds < 300) {
      _detectStation(event.position, canvasSize);
    }

    _pointerDownPos = null;
    _pointerDownTime = null;
  }

  /// Konversi posisi global tap → koordinat canvas (memperhitungkan zoom/pan),
  /// lalu cek jarak ke setiap stasiun.
  void _detectStation(Offset globalPos, Size canvasSize) {
    // Dapatkan posisi lokal relatif terhadap widget InteractiveViewer
    final RenderBox? box =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localPos = box.globalToLocal(globalPos);

    // Terapkan inverse transformation matrix untuk mendapatkan koordinat canvas asli
    final matrix = _transformController.value;
    final inverseMatrix = Matrix4.inverted(matrix);
    final canvasPos = MatrixUtils.transformPoint(inverseMatrix, localPos);

    // Cek jarak tap ke setiap stasiun (threshold 30px di koordinat canvas)
    for (final station in stations) {
      final stationPos = Offset(
        canvasSize.width * station.relativePosition.dx,
        canvasSize.height * station.relativePosition.dy,
      );
      final d = (canvasPos - stationPos).distance;
      if (d < 30) {
        widget.onStationSelected?.call(station.name);
        return;
      }
    }
  }

  /// Menganimasikan InteractiveViewer agar terfokus di stasiun tertentu
  void _centerOnStation(String stationName, Size canvasSize, {bool animate = true}) {
    final station = stations.firstWhere(
      (s) => s.name.toLowerCase() == stationName.toLowerCase(),
      orElse: () => stations.first,
    );

    final targetX = canvasSize.width * station.relativePosition.dx;
    final targetY = canvasSize.height * station.relativePosition.dy;

    // Tentukan zoom scale saat memfokuskan stasiun
    const double targetScale = 1.4;

    // Hitung pergeseran (translation) agar target berada tepat di tengah area yang terlihat
    // (di atas panel stasiun terpilih dengan menggesernya ke atas sebesar 130px)
    final double viewportWidth = canvasSize.width;
    final double viewportHeight = canvasSize.height;
    final double translationX = (viewportWidth / 2) - (targetX * targetScale);
    final double translationY = (viewportHeight / 2) - (targetY * targetScale) - 130;

    final Matrix4 targetMatrix = Matrix4.translationValues(translationX, translationY, 0.0)
        * Matrix4.diagonal3Values(targetScale, targetScale, 1.0);

    if (animate) {
      _animationMatrix = Matrix4Tween(
        begin: _transformController.value,
        end: targetMatrix,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ));
      _animationController.forward(from: 0.0);
    } else {
      _transformController.value = targetMatrix;
    }
  }

  /// Zoom in/out relatif terhadap tengah viewport
  void _zoom(double factor) {
    final currentMatrix = _transformController.value.clone();
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.8, 4.0);
    final scaleChange = newScale / currentScale;

    final RenderBox? box =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final center = Offset(box.size.width / 2, box.size.height / 2);

    final tx = currentMatrix.getTranslation().x;
    final ty = currentMatrix.getTranslation().y;

    final newTx = center.dx - (center.dx - tx) * scaleChange;
    final newTy = center.dy - (center.dy - ty) * scaleChange;

    final targetMatrix = Matrix4.translationValues(newTx, newTy, 0.0)
        * Matrix4.diagonal3Values(newScale, newScale, 1.0);

    _animationMatrix = Matrix4Tween(
      begin: _transformController.value,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Pantau perubahan stasiun terpilih untuk digeser ke tengah layar
        if (widget.selectedStation != _prevSelectedStation) {
          final tempPrev = _prevSelectedStation;
          _prevSelectedStation = widget.selectedStation;
          if (widget.selectedStation != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _centerOnStation(
                widget.selectedStation!,
                canvasSize,
                animate: tempPrev != null && _hasInitialized,
              );
              _hasInitialized = true;
            });
          }
        }

        // Listener menangkap raw pointer events di luar gesture arena.
        return Stack(
          children: [
            Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: (event) => _onPointerUp(event, canvasSize),
              child: SizedBox.expand(
                child: InteractiveViewer(
                  key: _viewerKey,
                  transformationController: _transformController,
                  minScale: 0.8,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(60),
                  child: CustomPaint(
                    size: canvasSize,
                    painter: SchematicMapPainter(
                      showColors: widget.showColors,
                      selectedStation: widget.selectedStation,
                    ),
                  ),
                ),
              ),
            ),

            // ── Tombol Zoom 🔍+ / 🔍- ──
            Positioned(
              right: 12,
              top: 12,
              child: Column(
                children: [
                  _ZoomButton(
                    icon: Icons.zoom_in,
                    onTap: () => _zoom(1.4),
                  ),
                  const SizedBox(height: 8),
                  _ZoomButton(
                    icon: Icons.zoom_out,
                    onTap: () => _zoom(0.7),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tombol zoom bulat dengan ikon magnifier glass
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
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
