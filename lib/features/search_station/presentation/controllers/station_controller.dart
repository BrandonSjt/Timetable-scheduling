import 'package:flutter/foundation.dart';
import '../../domain/entities/station.dart';
import '../../domain/repositories/station_repository.dart';

class StationController extends ChangeNotifier {
  StationController(this._repository);
  final StationRepository _repository;
  List<Station> _stations = const [];
  bool isLoading = false;
  String? error;
  String query = '';
  String filter = 'all';

  List<Station> filtered({String? excludedName}) {
    final needle = query.toLowerCase();
    return _stations
        .where((station) {
          if (station.name == excludedName ||
              station.shortName == excludedName) {
            return false;
          }
          final matchesQuery =
              needle.isEmpty ||
              station.name.toLowerCase().contains(needle) ||
              station.shortName.toLowerCase().contains(needle) ||
              (station.lineInfo ?? station.services).toLowerCase().contains(
                needle,
              ) ||
              station.publicCodes.any(
                (code) => code.toLowerCase().contains(needle),
              );
          final matchesFilter =
              filter == 'all' ||
              (filter == 'KRL' && station.isKrl) ||
              (filter == 'MRT' && station.isMrt) ||
              (filter == 'LRT' && station.isLrt) ||
              (filter == 'accessible' && station.isAccessible);
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _stations = await _repository.getStations();
    } catch (exception) {
      error = exception.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String value) {
    query = value;
    notifyListeners();
  }

  void selectFilter(String value) {
    filter = value;
    notifyListeners();
  }
}
