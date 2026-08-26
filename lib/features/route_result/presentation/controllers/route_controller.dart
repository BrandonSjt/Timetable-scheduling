import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/route_plan.dart';
import '../../domain/repositories/route_repository.dart';
import '../../domain/services/route_speech_service.dart';

enum RouteViewState { initial, loading, success, error }

class RouteController extends ChangeNotifier {
  RouteController(this._repository, this._speech);

  static const connectionError =
      'Tidak dapat memuat rute. Periksa koneksi dan coba lagi.';

  final RouteRepository _repository;
  final RouteSpeechService _speech;
  RouteViewState _state = RouteViewState.initial;
  RoutePreference _preference = RoutePreference.fastest;
  RoutePlan? _route;
  String? _from;
  String? _to;
  bool _isSpeaking = false;

  RouteViewState get state => _state;
  RoutePreference get preference => _preference;
  RoutePlan? get route => _route;
  bool get isSpeaking => _isSpeaking;
  String? get errorMessage =>
      _state == RouteViewState.error ? connectionError : null;

  RoutePreference get _apiPreference =>
      _preference == RoutePreference.minimumTransfers
      ? RoutePreference.minimumTransfers
      : RoutePreference.fastest;

  Future<void> load({required String from, required String to}) async {
    _from = from;
    _to = to;
    await _request();
  }

  Future<void> retry() async {
    if (_from != null && _to != null) await _request();
  }

  Future<void> selectPreference(RoutePreference preference) async {
    if (_preference == preference) return;
    final previousApiPreference = _apiPreference;
    _preference = preference;
    notifyListeners();
    if (_route == null || previousApiPreference != _apiPreference) {
      await _request();
    }
  }

  Future<void> _request() async {
    final from = _from;
    final to = _to;
    if (from == null || to == null) return;
    _state = RouteViewState.loading;
    notifyListeners();
    try {
      _route = await _repository.plan(
        from: from,
        to: to,
        preference: _apiPreference,
      );
      _state = RouteViewState.success;
    } catch (_) {
      _route = null;
      _state = RouteViewState.error;
    }
    notifyListeners();
  }

  Future<void> speak(String languageCode) async {
    final currentRoute = _route;
    if (currentRoute == null) return;
    _isSpeaking = true;
    notifyListeners();
    try {
      await _speech.speak(
        buildRouteNarration(currentRoute, languageCode),
        languageCode,
      );
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> repeat(String languageCode) async {
    await _speech.stop();
    await speak(languageCode);
  }

  Future<void> pause() async {
    await _speech.pause();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _speech.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_speech.stop());
    super.dispose();
  }
}
