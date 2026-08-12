import '../../domain/entities/station.dart';

class StationModel extends Station {
  const StationModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.shortName,
    required super.isLrt,
    required super.isKrl,
    required super.isMrt,
    required super.isAccessible,
    super.operationalCode,
    super.lineInfo,
    super.statusText,
    super.statusColor,
    super.publicCodes,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) => StationModel(
    id: json['id'] as String,
    slug: json['slug'] as String,
    name: (json['officialName'] ?? json['name']) as String,
    shortName: (json['shortName'] ?? json['name']) as String,
    operationalCode: json['operationalCode'] as String?,
    lineInfo: json['lineInfo'] as String?,
    statusText: json['statusText'] as String?,
    statusColor: json['statusColor'] as String?,
    isLrt: json['isLrt'] as bool? ?? false,
    isKrl: json['isKrl'] as bool? ?? false,
    isMrt: json['isMrt'] as bool? ?? false,
    isAccessible: json['isAccessible'] as bool? ?? false,
    publicCodes: (json['publicCodes'] as List<dynamic>? ?? const [])
        .map((value) => (value as Map<String, dynamic>)['code'] as String)
        .toList(growable: false),
  );
}
