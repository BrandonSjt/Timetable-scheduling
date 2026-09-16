import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/l10n/app_localizations.dart';
import 'package:timetable/features/home/data/krl_station_locations.dart';
import 'package:timetable/features/home/data/services/user_location_service.dart';
import 'package:timetable/features/home/domain/entities/station_geo_point.dart';
import 'package:timetable/features/home/domain/services/nearest_krl_station.dart';
import 'package:timetable/features/home/presentation/controllers/station_location_tracker.dart';
import 'package:timetable/features/home/presentation/widgets/map_widgets.dart';
import 'package:timetable/features/home/presentation/widgets/station_located_map.dart';
import 'package:timetable/shared/widgets/schematic_map_painter.dart';

import 'helpers/fake_tracking_location.dart';
import 'helpers/localized_test_app.dart';

void main() {
  final time = DateTime.utc(2026, 9, 15, 12);
  final manggarai = krlStationLocations.firstWhere(
    (s) => s.name == 'Manggarai',
  );
  final tebet = krlStationLocations.firstWhere((s) => s.name == 'Tebet');
  UserCoordinates fix(
    StationGeoPoint station, {
    double? accuracy = 5,
    DateTime? timestamp,
  }) => UserCoordinates(
    latitude: station.latitude,
    longitude: station.longitude,
    accuracyMeters: accuracy,
    timestamp: timestamp ?? time,
  );
  NearestKrlStationResult? resolve(
    UserCoordinates p, {
    List<StationGeoPoint> stations = krlStationLocations,
  }) => NearestKrlStation.findNearby(
    latitude: p.latitude,
    longitude: p.longitude,
    accuracyMeters: p.accuracyMeters,
    timestamp: p.timestamp,
    now: time,
    stations: stations,
  );

  test(
    'valid fixes resolve canonical nodes, invalid or old fixes never do',
    () {
      expect(
        resolve(fix(manggarai))?.station.schematicStationId,
        manggarai.schematicStationId,
      );
      expect(
        resolve(fix(tebet))?.station.schematicStationId,
        tebet.schematicStationId,
      );
      for (final position in [
        fix(manggarai, accuracy: 101),
        fix(manggarai, accuracy: -1),
        fix(manggarai, accuracy: double.nan),
        fix(manggarai, accuracy: double.infinity),
        fix(manggarai, accuracy: null),
        fix(manggarai, timestamp: time.subtract(const Duration(seconds: 30))),
        fix(manggarai, timestamp: time.add(const Duration(seconds: 1))),
        const UserCoordinates(latitude: -6.21, longitude: 106.85),
        UserCoordinates(
          latitude: double.nan,
          longitude: 106.85,
          accuracyMeters: 5,
          timestamp: time,
        ),
        UserCoordinates(
          latitude: 91,
          longitude: 181,
          accuracyMeters: 5,
          timestamp: time,
        ),
        UserCoordinates(
          latitude: 0,
          longitude: 0,
          accuracyMeters: 5,
          timestamp: time,
        ),
      ]) {
        expect(resolve(position), isNull);
      }
    },
  );

  test(
    'nearby threshold includes uncertainty and ambiguous stations are rejected',
    () {
      final near = UserCoordinates(
        latitude: manggarai.latitude + 0.002,
        longitude: manggarai.longitude,
        accuracyMeters: 5,
        timestamp: time,
      );
      expect(resolve(near), isNotNull);
      final uncertainEdge = UserCoordinates(
        latitude: manggarai.latitude + 0.0025,
        longitude: manggarai.longitude,
        accuracyMeters: 50,
        timestamp: time,
      );
      expect(resolve(uncertainEdge), isNull);
      final other = StationGeoPoint(
        schematicStationId: 'other',
        name: 'Other',
        latitude: manggarai.latitude + 0.0005,
        longitude: manggarai.longitude,
      );
      expect(
        resolve(fix(manggarai, accuracy: 40), stations: [manggarai, other]),
        isNull,
      );
      expect(
        resolve(fix(manggarai, accuracy: 5), stations: [manggarai, other]),
        isNotNull,
      );
    },
  );

  testWidgets(
    'tracker clears exact expiry and keeps no subscriptions after stop',
    (tester) async {
      final gateway = FakeTrackingLocation();
      var now = time;
      final tracker = StationLocationTracker(
        service: UserLocationService(gateway: gateway),
        stations: krlStationLocations,
        now: () => now,
      );
      await tracker.start();
      gateway.positions.add(fix(manggarai));
      expect(tracker.nearby?.station.name, 'Manggarai');
      await tester.pump(const Duration(seconds: 29));
      expect(tracker.nearby, isNotNull);
      now = time.add(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 1));
      expect(tracker.nearby, isNull);
      gateway.positions.add(fix(tebet, timestamp: now));
      expect(tracker.nearby?.station.name, 'Tebet');
      gateway.positions.add(fix(tebet, accuracy: 300, timestamp: now));
      expect(tracker.nearby, isNull);
      tracker.stop();
      expect(gateway.positions.hasListener, isFalse);
      expect(gateway.services.hasListener, isFalse);
      tracker.dispose();
      await gateway.dispose();
    },
  );

  testWidgets(
    'disabled GPS, stream errors and completed stream clear the marker',
    (tester) async {
      for (final trigger in ['disabled', 'error', 'done']) {
        final gateway = FakeTrackingLocation();
        final tracker = StationLocationTracker(
          service: UserLocationService(gateway: gateway),
          stations: krlStationLocations,
          now: () => time,
        );
        await tracker.start();
        gateway.positions.add(fix(manggarai));
        if (trigger == 'disabled') gateway.services.add(false);
        if (trigger == 'error') gateway.positions.addError(StateError('GPS'));
        if (trigger == 'done') await gateway.positions.close();
        await tester.pump();
        expect(tracker.nearby, isNull);
        expect(
          tracker.failure,
          trigger == 'disabled'
              ? UserLocationStatus.servicesDisabled
              : UserLocationStatus.unavailable,
        );
        expect(gateway.positions.hasListener, isFalse);
        tracker.dispose();
        await gateway.dispose();
      }
    },
  );

  testWidgets(
    'permission continuation after stop cannot start GPS; silent resume does not request denied permission',
    (tester) async {
      final gateway = FakeTrackingLocation()
        ..permission = AppLocationPermission.denied;
      final granted = Completer<AppLocationPermission>();
      gateway.pendingPermission = granted.future;
      final tracker = StationLocationTracker(
        service: UserLocationService(gateway: gateway),
        stations: krlStationLocations,
      );
      final started = tracker.start(requestPermission: true);
      await tester.pump();
      tracker.stop();
      granted.complete(AppLocationPermission.whileInUse);
      await started;
      expect(gateway.positions.hasListener, isFalse);
      expect(tracker.nearby, isNull);
      await tracker.start();
      expect(gateway.permissionRequests, 1);
      expect(tracker.failure, UserLocationStatus.permissionDenied);
      tracker.dispose();
      await gateway.dispose();
    },
  );

  testWidgets(
    'first fix timeout is recoverable, disposal rejects pending callbacks',
    (tester) async {
      final gateway = FakeTrackingLocation();
      final tracker = StationLocationTracker(
        service: UserLocationService(gateway: gateway),
        stations: krlStationLocations,
        now: () => time,
      );
      await tracker.start();
      await tester.pump(const Duration(seconds: 10));
      expect(tracker.loading, isFalse);
      expect(tracker.failure, UserLocationStatus.unavailable);
      gateway.positions.add(fix(manggarai));
      expect(tracker.failure, isNull);
      expect(tracker.nearby, isNotNull);
      tracker.dispose();
      gateway.positions.add(fix(tebet));
      expect(tracker.nearby, isNull);
      await gateway.dispose();
    },
  );

  testWidgets(
    'map GPS follows node without changing selection or pan; pause cancels and resume needs fresh fix',
    (tester) async {
      final gateway = FakeTrackingLocation();
      await tester.pumpWidget(
        localizedTestApp(
          home: Scaffold(
            body: StationLocatedMap(
              selectedStation: 'Tebet',
              locationService: UserLocationService(gateway: gateway),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      UserCoordinates current(StationGeoPoint station) =>
          fix(station, timestamp: DateTime.now());
      gateway.positions.add(current(manggarai));
      await tester.pumpAndSettle();
      expect(find.text('Kamu di sini · Dekat Stasiun Manggarai'), findsNothing);
      expect(
        tester.widget<MapView>(find.byType(MapView)).nearestStationLabel,
        'Kamu di sini',
      );
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final matrix = viewer.transformationController!.value.clone();
      gateway.positions.add(current(tebet));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MapView>(find.byType(MapView)).selectedStation,
        'Tebet',
      );
      expect(
        tester
            .widget<InteractiveViewer>(find.byType(InteractiveViewer))
            .transformationController!
            .value,
        matrix,
      );
      final paint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(MapView),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect(
        (paint.painter! as SchematicMapPainter).nearestStation,
        tebet.schematicStationId,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(gateway.positions.hasListener, isFalse);
      // Paused Flutter doesn't rebuild frames; state is verified on resume.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(
        tester.widget<MapView>(find.byType(MapView)).nearestStationId,
        isNull,
      );
      gateway.positions.add(current(manggarai));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MapView>(find.byType(MapView)).nearestStationId,
        manggarai.schematicStationId,
      );
      await tester.pumpWidget(const SizedBox());
      expect(gateway.positions.hasListener, isFalse);
      await gateway.dispose();
    },
  );

  testWidgets('compact map and large text keep status usable in all locales', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in AppLocalizations.supportedLocales) {
      final gateway = FakeTrackingLocation();
      await tester.pumpWidget(
        localizedTestApp(
          locale: locale,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: StationLocatedMap(
                key: UniqueKey(),
                locationService: UserLocationService(gateway: gateway),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      gateway.positions.add(fix(manggarai, timestamp: DateTime.now()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('station-location-status')), findsNothing);
      await tester.tap(find.byKey(const Key('locate-user-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('station-location-details')), findsOneWidget);
      expect(gateway.positions.hasListener, isTrue);
      expect(tester.takeException(), isNull);
      gateway.positions.add(
        fix(manggarai, accuracy: 500, timestamp: DateTime.now()),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<MapView>(find.byType(MapView)).nearestStationLabel,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('station-location-action')),
            )
            .onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
      await gateway.dispose();
    }
  });

  testWidgets(
    'covered route releases GPS and locate focus never changes selection',
    (tester) async {
      final gateway = FakeTrackingLocation();
      await tester.pumpWidget(
        localizedTestApp(
          home: Scaffold(
            body: StationLocatedMap(
              selectedStation: 'Tebet',
              locationService: UserLocationService(gateway: gateway),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      gateway.positions.add(fix(manggarai, timestamp: DateTime.now()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('locate-user-button')));
      await tester.pumpAndSettle();
      expect(gateway.positions.hasListener, isTrue);
      await tester.tap(find.byKey(const Key('station-location-action')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MapView>(find.byType(MapView)).selectedStation,
        'Tebet',
      );
      expect(
        tester.widget<MapView>(find.byType(MapView)).focusStationId,
        manggarai.schematicStationId,
      );
      final context = tester.element(find.byType(StationLocatedMap));
      final navigator = Navigator.of(context);
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Another page')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(gateway.positions.hasListener, isFalse);
      navigator.pop();
      await tester.pumpAndSettle();
      expect(gateway.positions.hasListener, isTrue);
      expect(
        tester.widget<MapView>(find.byType(MapView)).nearestStationId,
        isNull,
      );
      await tester.pumpWidget(const SizedBox());
      await gateway.dispose();
    },
  );
}
