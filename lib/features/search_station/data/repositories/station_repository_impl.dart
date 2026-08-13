import '../../domain/entities/station.dart';
import '../../domain/repositories/station_repository.dart';
import '../datasources/station_remote_data_source.dart';

class StationRepositoryImpl implements StationRepository {
  StationRepositoryImpl(this._remote);
  final StationRemoteDataSource _remote;
  List<Station>? _cache;

  @override
  Future<List<Station>> getStations() async =>
      _cache ??= await _remote.getStations();
}
