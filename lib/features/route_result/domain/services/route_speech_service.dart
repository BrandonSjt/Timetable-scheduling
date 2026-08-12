import '../entities/route_plan.dart';

abstract interface class RouteSpeechService {
  Future<void> speak(String text, String languageCode);
  Future<void> pause();
  Future<void> stop();
}

String _rupiah(int value) => value.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  (match) => '${match[1]}.',
);

String buildRouteNarration(RoutePlan route, String languageCode) {
  final summary = languageCode == 'en'
      ? 'Route from ${route.from} to ${route.to}. '
            'Estimated travel time is ${route.travelTime} minutes. '
            'Fare is ${route.currency} ${_rupiah(route.fare)}.'
      : 'Rute dari ${route.from} menuju ${route.to}. '
            'Estimasi waktu ${route.travelTime} menit. '
            'Tarif Rp${_rupiah(route.fare)}.';
  final steps = route.steps
      .map((step) => '${step.text}. ${step.detailNote}. ${step.durationText}.')
      .join(' ');
  return '$summary $steps'.trim();
}
