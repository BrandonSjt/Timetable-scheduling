import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timetable/features/search_station/data/datasources/station_remote_data_source.dart';
import 'package:timetable/features/timetable/domain/entities/train_schedule.dart';
import 'package:timetable/features/timetable/presentation/controllers/timetable_controller.dart';
import 'package:timetable/features/timetable/presentation/pages/timetable_page.dart';
import 'package:timetable/l10n/app_localizations.dart';
import 'helpers/localized_test_app.dart';

class _Controller implements TimetableController {
  final List<String?> requested = [];
  @override
  Future<List<TrainSchedule>> loadSchedules({
    String? station,
    String? trainType,
    bool? isWeekend,
  }) async {
    requested.add(station);
    return [];
  }
}

void main() {
  testWidgets(
    'picker uses server catalogue and selected station reaches schedule query without Material exceptions',
    (tester) async {
      final controller = _Controller();
      final source = StationRemoteDataSource(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'data': [
                {
                  'id': '1',
                  'slug': 'jurangmangu',
                  'name': 'Jurangmangu',
                  'isKrl': true,
                },
                {'id': '2', 'slug': 'jatake', 'name': 'Jatake', 'isKrl': true},
              ],
            }),
            200,
          ),
        ),
      );
      await tester.pumpWidget(
        localizedTestApp(
          locale: const Locale('id'),
          home: TimetablePage(
            controller: controller,
            stationDataSource: source,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.requested, ['Semua Stasiun']);
      await tester.tap(find.byIcon(Icons.location_on_outlined).first);
      await tester.pumpAndSettle();
      expect(find.text('Jurangmangu'), findsOneWidget);
      expect(find.text('Jatake'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Jurangmangu'));
      await tester.pumpAndSettle();
      expect(controller.requested.last, 'Jurangmangu');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'catalogue error offers recovery and never claims partial list is complete',
    (tester) async {
      var fail = true;
      final source = StationRemoteDataSource(
        client: MockClient(
          (_) async => fail
              ? http.Response('{}', 503)
              : http.Response(
                  jsonEncode({
                    'data': [
                      {
                        'id': '1',
                        'slug': 'bogor',
                        'name': 'Bogor',
                        'isKrl': true,
                      },
                    ],
                  }),
                  200,
                ),
        ),
      );
      await tester.pumpWidget(
        localizedTestApp(
          locale: const Locale('id'),
          home: TimetablePage(
            controller: _Controller(),
            stationDataSource: source,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(TimetablePage)),
      )!;
      await tester.tap(find.text(l10n.filterOriginAll));
      await tester.pumpAndSettle();
      expect(find.text(l10n.scheduleStationCatalogError), findsOneWidget);
      fail = false;
      await tester.tap(find.text(l10n.actionRetry));
      await tester.pumpAndSettle();
      expect(find.text(l10n.scheduleStationCatalogError), findsNothing);
      expect(find.text('Bogor'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
