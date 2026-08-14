import '../../domain/entities/route_plan.dart';

class RoutePlanModel extends RoutePlan {
  const RoutePlanModel({
    required super.from,
    required super.to,
    required super.travelTime,
    required super.fare,
    required super.unitFare,
    required super.currency,
    required super.passengerCount,
    required super.stops,
    required super.serviceInfo,
    required super.hasTransit,
    required super.transferCount,
    required super.preference,
    required super.steps,
    required super.stationSequence,
    required super.exitGateA,
    required super.exitGateB,
  });

  factory RoutePlanModel.fromJson(Map<String, dynamic> json) => RoutePlanModel(
    from: json['from'] as String,
    to: json['to'] as String,
    travelTime: json['travelTime'] as int,
    fare: json['fare'] as int,
    unitFare: json['unitFare'] as int,
    currency: json['currency'] as String,
    passengerCount: json['passengerCount'] as int,
    stops: json['stops'] as int,
    serviceInfo: json['serviceInfo'] as String,
    hasTransit: json['hasTransit'] as bool,
    transferCount: json['transferCount'] as int? ?? 0,
    preference: RoutePreference.fromApi(
      json['preference'] as String? ?? 'FASTEST',
    ),
    steps: (json['steps'] as List<dynamic>)
        .map((value) => _stepFromJson(value as Map<String, dynamic>))
        .toList(growable: false),
    stationSequence: (json['stationSequence'] as List<dynamic>)
        .map((value) => _stationFromJson(value as Map<String, dynamic>))
        .toList(growable: false),
    exitGateA: json['exitGateA'] as String? ?? '',
    exitGateB: json['exitGateB'] as String? ?? '',
  );

  static RoutePlanStep _stepFromJson(Map<String, dynamic> json) {
    final isHeader = json['isHeader'] as bool? ?? false;
    final isTransit = json['isTransit'] as bool? ?? false;
    final isDestination = json['isDestination'] as bool? ?? false;
    return RoutePlanStep(
      kind: RouteStepKind.fromApi(
        json['kind'] as String?,
        isHeader: isHeader,
        isTransit: isTransit,
        isDestination: isDestination,
      ),
      isWalking: json['isWalking'] as bool? ?? false,
      text: json['text'] as String,
      durationText: json['durationText'] as String,
      detailNote: json['detailNote'] as String? ?? '',
      icon: json['icon'] as String,
      color: json['color'] as String,
      isHeader: isHeader,
      isTransit: isTransit,
      isDestination: isDestination,
    );
  }

  static RouteStation _stationFromJson(Map<String, dynamic> json) {
    final line = json['line'] as Map<String, dynamic>;
    return RouteStation(
      stationId: json['stationId'] as String,
      name: json['name'] as String,
      nodeCode: json['nodeCode'] as String?,
      line: RouteLine(
        id: line['id'] as String,
        slug: line['slug'] as String? ?? '',
        name: line['name'] as String,
        color: line['color'] as String,
        serviceType: line['serviceType'] as String,
      ),
    );
  }
}
