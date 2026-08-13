import '../entities/station.dart';

abstract interface class StationRepository {
  Future<List<Station>> getStations();
}
