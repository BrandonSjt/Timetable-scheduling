import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/route_plan.dart';

class RouteJourneyTimeline extends StatelessWidget {
  const RouteJourneyTimeline({
    required this.title,
    required this.steps,
    super.key,
  });

  final String title;
  final List<RoutePlanStep> steps;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.alt_route_rounded, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      const SizedBox(height: 14),
      for (var index = 0; index < steps.length; index++)
        _TimelineStep(
          index: index,
          step: steps[index],
          previous: index == 0 ? null : steps[index - 1],
          hasNext: index < steps.length - 1,
        ),
    ],
  );
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.index,
    required this.step,
    required this.previous,
    required this.hasNext,
  });

  final int index;
  final RoutePlanStep step;
  final RoutePlanStep? previous;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    final color = _color(step.color);
    final markerColor = step.isWalking ? AppColors.textSecondary : color;
    final previousStep = previous;
    final beforeWalking = previousStep?.isWalking ?? false;
    final afterWalking = step.isWalking;

    return Semantics(
      label: [
        step.text,
        step.detailNote,
        step.durationText,
      ].where((part) => part.trim().isNotEmpty).join('. '),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: step.isWalking
                  ? ValueKey('route-timeline-walk-$index')
                  : null,
              width: 38,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _TimelineRailPainter(
                      drawBefore: previousStep != null,
                      drawAfter: hasNext,
                      beforeColor: beforeWalking
                          ? AppColors.textSecondary
                          : _color(previousStep?.color ?? step.color),
                      afterColor:
                          afterWalking || step.kind == RouteStepKind.transfer
                          ? AppColors.textSecondary
                          : color,
                      beforeDashed: beforeWalking,
                      afterDashed: afterWalking,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: markerColor.withValues(alpha: 0.12),
                          border: Border.all(
                            color: markerColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Icon(
                          _icon(step.icon),
                          size: 18,
                          color: markerColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.text,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          if (step.detailNote.isNotEmpty)
                            Text(
                              step.detailNote,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      step.durationText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRailPainter extends CustomPainter {
  const _TimelineRailPainter({
    required this.drawBefore,
    required this.drawAfter,
    required this.beforeColor,
    required this.afterColor,
    required this.beforeDashed,
    required this.afterDashed,
  });

  final bool drawBefore;
  final bool drawAfter;
  final Color beforeColor;
  final Color afterColor;
  final bool beforeDashed;
  final bool afterDashed;

  static const markerCenter = 28.0;
  static const markerRadius = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    if (drawBefore) {
      _drawLine(
        canvas,
        Offset(x, 0),
        Offset(x, markerCenter - markerRadius),
        beforeColor,
        beforeDashed,
      );
    }
    if (drawAfter) {
      _drawLine(
        canvas,
        Offset(x, markerCenter + markerRadius),
        Offset(x, size.height),
        afterColor,
        afterDashed,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    bool dashed,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(start, end, paint);
      return;
    }
    for (var y = start.dy; y < end.dy; y += 8) {
      canvas.drawLine(
        Offset(start.dx, y),
        Offset(end.dx, (y + 4).clamp(start.dy, end.dy)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineRailPainter oldDelegate) =>
      drawBefore != oldDelegate.drawBefore ||
      drawAfter != oldDelegate.drawAfter ||
      beforeColor != oldDelegate.beforeColor ||
      afterColor != oldDelegate.afterColor ||
      beforeDashed != oldDelegate.beforeDashed ||
      afterDashed != oldDelegate.afterDashed;
}

Color _color(String value) {
  final hex = value.replaceFirst('#', '');
  return hex.length == 6
      ? Color(int.parse('FF$hex', radix: 16))
      : AppColors.primaryBlue;
}

IconData _icon(String value) => switch (value) {
  'directions_walk' => Icons.directions_walk_rounded,
  'sync_alt' => Icons.sync_alt_rounded,
  'place' => Icons.place_rounded,
  _ => Icons.train_rounded,
};
