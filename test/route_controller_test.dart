import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/route_result/domain/entities/route_plan.dart';
import 'package:timetable/features/route_result/domain/repositories/route_repository.dart';
import 'package:timetable/features/route_result/domain/services/route_speech_service.dart';
import 'package:timetable/features/route_result/presentation/controllers/route_controller.dart';
import 'helpers/route_test_data.dart';

class _Repository implements RouteRepository {
  bool fail = false;
  final calls = <RoutePreference>[];

  @override
  Future<RoutePlan> plan({
    required String from,
    required String to,
    required RoutePreference preference,
    int passengerCount = 1,
  }) async {
    calls.add(preference);
    if (fail) throw Exception('offline');
    return testRoute;
  }
}

class _Speech implements RouteSpeechService {
  final spoken = <String>[];
  int pauseCount = 0;
  int stopCount = 0;

  @override
  Future<void> speak(String text, String languageCode) async {
    spoken.add('$languageCode:$text');
  }

  @override
  Future<void> pause() async => pauseCount++;

  @override
  Future<void> stop() async => stopCount++;
}

void main() {
  test(
    'controller loads, changes route mode, and exposes exact failure',
    () async {
      final repository = _Repository();
      final controller = RouteController(repository, _Speech());

      await controller.load(from: 'bogor', to: 'tangerang');
      expect(controller.state, RouteViewState.success);
      expect(controller.route?.from, 'Bogor');
      expect(repository.calls, [RoutePreference.fastest]);

      await controller.selectPreference(RoutePreference.minimumTransfers);
      expect(repository.calls.last, RoutePreference.minimumTransfers);

      repository.fail = true;
      await controller.retry();
      expect(controller.state, RouteViewState.error);
      expect(
        controller.errorMessage,
        'Tidak dapat memuat rute. Periksa koneksi dan coba lagi.',
      );
    },
  );

  test('accessible mode narrates fastest route and controls speech', () async {
    final repository = _Repository();
    final speech = _Speech();
    final controller = RouteController(repository, speech);
    await controller.load(from: 'bogor', to: 'tangerang');

    await controller.selectPreference(RoutePreference.accessible);
    expect(controller.preference, RoutePreference.accessible);
    expect(repository.calls, [RoutePreference.fastest]);

    await controller.speak('id');
    expect(speech.spoken.single, contains('Bogor menuju Tangerang'));
    await controller.pause();
    await controller.stop();
    expect(speech.pauseCount, 1);
    expect(speech.stopCount, 1);
  });
}
