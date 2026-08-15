class StationGeoPoint {
  const StationGeoPoint({
    required this.schematicStationId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String schematicStationId;
  final String name;
  final double latitude;
  final double longitude;
}
