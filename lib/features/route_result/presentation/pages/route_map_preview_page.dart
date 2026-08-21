import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/map_widgets.dart';
import '../../domain/entities/route_plan.dart';

class RouteMapPreviewPage extends StatefulWidget {
  const RouteMapPreviewPage({super.key, required this.route});

  final RoutePlan? route;

  @override
  State<RouteMapPreviewPage> createState() => _RouteMapPreviewPageState();
}

class _RouteMapPreviewPageState extends State<RouteMapPreviewPage> {
  bool _showAllLines = false;

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    if (route == null || route.lineSlugs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview Perjalanan')),
        body: const Center(child: Text('Preview line tidak tersedia.')),
      );
    }

    final journeyLines = route.journeyLines;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _PreviewHeader(route: route),
            Expanded(
              child: MapView(
                showColors: true,
                selectedStation: route.from,
                fromStation: route.from,
                visibleLineIds: _showAllLines ? null : route.lineSlugs,
              ),
            ),
            _PreviewControls(
              route: route,
              journeyLines: journeyLines,
              showAllLines: _showAllLines,
              onShowAllLines: () => setState(() => _showAllLines = true),
              onFocusJourney: () => setState(() => _showAllLines = false),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.route});

  final RoutePlan route;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 6, 16, 12),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
    ),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Kembali ke hasil perjalanan',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preview Line Perjalanan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                '${route.from}  →  ${route.to}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PreviewControls extends StatelessWidget {
  const _PreviewControls({
    required this.route,
    required this.journeyLines,
    required this.showAllLines,
    required this.onShowAllLines,
    required this.onFocusJourney,
  });

  final RoutePlan route;
  final List<RouteLine> journeyLines;
  final bool showAllLines;
  final VoidCallback onShowAllLines;
  final VoidCallback onFocusJourney;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.cardBorder)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You Are Here: ${route.from}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: showAllLines ? onFocusJourney : onShowAllLines,
              child: Text(showAllLines ? 'Fokus Perjalanan' : 'Semua Line'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final line in journeyLines)
              Chip(
                avatar: CircleAvatar(backgroundColor: _parseColor(line.color)),
                label: Text(line.name),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Line lain diredupkan agar rute perjalanan lebih mudah dilihat.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    ),
  );

  Color _parseColor(String value) {
    final normalized = value.replaceFirst('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.tryParse(hex, radix: 16) ?? 0xFF2563EB);
  }
}
