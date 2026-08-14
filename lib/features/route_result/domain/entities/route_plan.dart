enum RoutePreference {
  fastest('FASTEST'),
  minimumTransfers('MIN_TRANSFERS'),
  accessible('FASTEST');

  const RoutePreference(this.apiValue);
  final String apiValue;

  static RoutePreference fromApi(String value) =>
      value == 'MIN_TRANSFERS' ? minimumTransfers : fastest;
}

class RouteLine {
  const RouteLine({
    required this.id,
    required this.slug,
    required this.name,
    required this.color,
    required this.serviceType,
  });

  final String id;
  final String slug;
  final String name;
  final String color;
  final String serviceType;
}

class RouteStation {
  const RouteStation({
    required this.stationId,
    required this.name,
    required this.line,
    this.nodeCode,
  });

  final String stationId;
  final String name;
  final String? nodeCode;
  final RouteLine line;
}

enum RouteStepKind {
  board,
  transfer,
  continueTrip,
  arrive;

  static RouteStepKind fromApi(
    String? value, {
    required bool isHeader,
    required bool isTransit,
    required bool isDestination,
  }) {
    if (value == 'board') return board;
    if (value == 'transfer') return transfer;
    if (value == 'continue') return continueTrip;
    if (value == 'arrive') return arrive;
    if (isDestination) return arrive;
    if (isTransit) return transfer;
    if (isHeader) return board;
    return continueTrip;
  }
}

class RoutePlanStep {
  const RoutePlanStep({
    required this.kind,
    required this.isWalking,
    required this.text,
    required this.durationText,
    required this.detailNote,
    required this.icon,
    required this.color,
    required this.isHeader,
    required this.isTransit,
    required this.isDestination,
  });

  final RouteStepKind kind;
  final bool isWalking;
  final String text;
  final String durationText;
  final String detailNote;
  final String icon;
  final String color;
  final bool isHeader;
  final bool isTransit;
  final bool isDestination;
}

class RoutePlan {
  const RoutePlan({
    required this.from,
    required this.to,
    required this.travelTime,
    required this.fare,
    required this.unitFare,
    required this.currency,
    required this.passengerCount,
    required this.stops,
    required this.serviceInfo,
    required this.hasTransit,
    required this.transferCount,
    required this.preference,
    required this.steps,
    required this.stationSequence,
    required this.exitGateA,
    required this.exitGateB,
  });

  final String from;
  final String to;
  final int travelTime;
  final int fare;
  final int unitFare;
  final String currency;
  final int passengerCount;
  final int stops;
  final String serviceInfo;
  final bool hasTransit;
  final int transferCount;
  final RoutePreference preference;
  final List<RoutePlanStep> steps;
  final List<RouteStation> stationSequence;
  final String exitGateA;
  final String exitGateB;
}
