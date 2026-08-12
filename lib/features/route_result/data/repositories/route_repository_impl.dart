import '../../domain/entities/route_plan.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/route_remote_data_source.dart';

class RouteRepositoryImpl implements RouteRepository {
  const RouteRepositoryImpl(this._remote);

  final RouteRemoteDataSource _remote;

  @override
  Future<RoutePlan> plan({
    required String from,
    required String to,
    required RoutePreference preference,
    int passengerCount = 1,
  }) => _remote.plan(
    from: from,
    to: to,
    preference: preference,
    passengerCount: passengerCount,
  );
}
