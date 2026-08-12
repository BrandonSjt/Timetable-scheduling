import '../entities/route_plan.dart';

abstract interface class RouteRepository {
  Future<RoutePlan> plan({
    required String from,
    required String to,
    required RoutePreference preference,
    int passengerCount = 1,
  });
}
