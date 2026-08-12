import '../entities/station.dart';

String buildStationVoiceGuide(List<Station> stations, String languageCode) {
  final isEnglish = languageCode == 'en';
  if (stations.isEmpty) {
    return isEnglish
        ? 'No stations match your search.'
        : 'Tidak ada stasiun yang sesuai dengan pencarian.';
  }

  final details = stations.take(5).map((station) => station.name).join('. ');
  final count = stations.length;
  final summary = isEnglish
      ? 'Found $count ${count == 1 ? 'station' : 'stations'}. Top results:'
      : 'Ditemukan $count stasiun. Hasil teratas:';
  return '$summary $details.';
}
