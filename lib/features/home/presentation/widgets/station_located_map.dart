import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/schematic_map_painter.dart';
import '../../data/krl_station_locations.dart';
import '../../data/services/user_location_service.dart';
import '../../domain/entities/station_geo_point.dart';
import '../controllers/station_location_tracker.dart';
import 'map_widgets.dart';

/// Foreground location overlay; station selection and map geometry stay separate.
class StationLocatedMap extends StatefulWidget {
  const StationLocatedMap({
    super.key,
    this.showColors = false,
    this.selectedStation,
    this.fromStation,
    this.visibleLineIds,
    this.onStationSelected,
    this.locationService = const UserLocationService(),
    this.stationLocations = krlStationLocations,
  });

  final bool showColors;
  final String? selectedStation;
  final String? fromStation;
  final Set<String>? visibleLineIds;
  final ValueChanged<String>? onStationSelected;
  final UserLocationService locationService;
  final List<StationGeoPoint> stationLocations;

  @override
  State<StationLocatedMap> createState() => _StationLocatedMapState();
}

class _StationLocatedMapState extends State<StationLocatedMap>
    with WidgetsBindingObserver {
  late final StationLocationTracker _tracker;
  bool _foreground = true;
  bool _surfaceActive = false;
  bool _initialPermissionAttempted = false;
  int _focusRequest = 0;
  String? _focusStationId;
  bool _detailsOpen = false;

  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _tracker = StationLocationTracker(
      service: widget.locationService,
      stations: widget.stationLocations
          .where(
            (point) => stations.any(
              (node) => node.id == point.schematicStationId && !node.isWaypoint,
            ),
          )
          .toList(),
    )..addListener(_changed);
    WidgetsBinding.instance.addObserver(this);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible =
        TickerMode.valuesOf(context).enabled &&
        (_detailsOpen || (ModalRoute.of(context)?.isCurrent ?? true));
    if (visible != _surfaceActive) {
      _surfaceActive = visible;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncTracking();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A permission dialog may cause inactive; don't cancel its own request.
    if (state == AppLifecycleState.inactive) return;
    _foreground = state == AppLifecycleState.resumed;
    _syncTracking();
  }

  void _syncTracking() {
    if (!_foreground || !_surfaceActive) {
      _tracker.stop();
    } else if (!_tracker.active && _tracker.failure == null) {
      final request = !_initialPermissionAttempted;
      _initialPermissionAttempted = true;
      unawaited(_tracker.start(requestPermission: request));
    }
  }

  void _focusLocation() {
    if (!_foreground || !_surfaceActive || _tracker.loading) return;
    final nearby = _tracker.nearby;
    if (nearby != null) {
      setState(() {
        _focusStationId = nearby.station.schematicStationId;
        ++_focusRequest;
      });
    } else {
      unawaited(_tracker.start(requestPermission: true));
    }
  }

  String _statusMessage(AppLocalizations l10n) {
    final nearby = _tracker.nearby;
    if (nearby != null) return l10n.mapNearStation(nearby.station.name);
    if (_tracker.loading) return l10n.mapLocationLoading;
    return switch (_tracker.failure) {
      UserLocationStatus.servicesDisabled => l10n.mapLocationServiceDisabled,
      UserLocationStatus.permissionDenied ||
      UserLocationStatus.permissionDeniedForever =>
        l10n.mapLocationPermissionDenied,
      UserLocationStatus.unavailable => l10n.mapLocationUnavailable,
      _ => l10n.mapLocationUnconfirmed,
    };
  }

  Future<void> _showLocationDetails() async {
    if (_detailsOpen || !_foreground || !_surfaceActive) return;
    _detailsOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => ListenableBuilder(
          listenable: _tracker,
          builder: (context, _) {
            final l10n = AppLocalizations.of(context)!;
            return SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.6,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    key: const Key('station-location-details'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.mapLocateMe,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(_statusMessage(l10n)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.mapNearestMarkerNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        key: const Key('station-location-action'),
                        onPressed: _tracker.loading
                            ? null
                            : () {
                                if (_tracker.nearby != null) {
                                  Navigator.of(sheetContext).pop();
                                  _focusLocation();
                                } else {
                                  unawaited(
                                    _tracker.start(requestPermission: true),
                                  );
                                }
                              },
                        icon: Icon(
                          _tracker.nearby != null
                              ? Icons.my_location_rounded
                              : Icons.refresh_rounded,
                        ),
                        label: Text(
                          _tracker.nearby != null
                              ? l10n.mapLocateMe
                              : l10n.actionRetry,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } finally {
      _detailsOpen = false;
      if (mounted) {
        _surfaceActive =
            TickerMode.valuesOf(context).enabled &&
            (ModalRoute.of(context)?.isCurrent ?? true);
        _syncTracking();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tracker.removeListener(_changed);
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nearby = _tracker.nearby;
    return MapView(
      showColors: widget.showColors,
      selectedStation: widget.selectedStation,
      fromStation: widget.fromStation,
      visibleLineIds: widget.visibleLineIds,
      onStationSelected: widget.onStationSelected,
      nearestStationId: nearby?.station.schematicStationId,
      onLocateUser: _showLocationDetails,
      isLocating: _tracker.loading,
      focusStationId: _focusStationId,
      focusRequest: _focusRequest,
      locationStatusLabel: _statusMessage(l10n),
      nearestStationLabel: nearby == null ? null : l10n.mapYouAreHere,
    );
  }
}
