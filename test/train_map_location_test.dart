import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/home/data/services/user_location_service.dart';
import 'package:timetable/features/home/domain/entities/station_geo_point.dart';
import 'package:timetable/features/home/presentation/pages/train_map_page.dart';

import 'helpers/localized_test_app.dart';

void main() {
  const nearbyStation = StationGeoPoint(
    schematicStationId: 'manggarai_cb',
    name: 'Manggarai',
    latitude: -6.2101704,
    longitude: 106.849935,
  );

  void usePhoneViewport(WidgetTester tester) {
    // Match the existing page's wide demo layout; responsive cleanup is a
    // separate concern from the location interaction covered here.
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('shows loading then the nearest KRL station', (tester) async {
    usePhoneViewport(tester);
    final completer = Completer<UserCoordinates?>();
    final gateway = MapLocationGateway(currentPosition: completer.future);

    await tester.pumpWidget(
      localizedTestApp(
        home: TrainMapPage(
          locationService: UserLocationService(gateway: gateway),
          stationLocations: const [nearbyStation],
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('locate-user-button')));
    await tester.pump();
    expect(find.byKey(const Key('locate-user-progress')), findsOneWidget);

    completer.complete(
      const UserCoordinates(latitude: -6.2102, longitude: 106.8499),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anda berada di dekat Stasiun Manggarai'), findsOneWidget);
    expect(find.textContaining('titik stasiun terdekat'), findsOneWidget);
  });

  testWidgets('shows feedback when location permission is denied', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final gateway = MapLocationGateway(
      permission: AppLocationPermission.denied,
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: TrainMapPage(
          locationService: UserLocationService(gateway: gateway),
          stationLocations: const [nearbyStation],
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('locate-user-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Izin lokasi dibutuhkan untuk menemukan stasiun terdekat.'),
      findsOneWidget,
    );
  });
}

class MapLocationGateway implements LocationGateway {
  MapLocationGateway({
    this.permission = AppLocationPermission.whileInUse,
    Future<UserCoordinates?>? currentPosition,
  }) : currentPosition =
           currentPosition ??
           Future<UserCoordinates?>.value(
             const UserCoordinates(latitude: -6.21, longitude: 106.85),
           );

  final AppLocationPermission permission;
  final Future<UserCoordinates?> currentPosition;

  @override
  Future<AppLocationPermission> checkPermission() async => permission;

  @override
  Future<UserCoordinates?> getCurrentPosition() => currentPosition;

  @override
  Future<UserCoordinates?> getLastKnownPosition() async => null;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<AppLocationPermission> requestPermission() async => permission;
}
