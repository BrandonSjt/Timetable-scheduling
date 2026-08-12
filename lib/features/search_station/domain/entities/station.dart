class Station {
  const Station({
    required this.id,
    required this.slug,
    required this.name,
    required this.shortName,
    required this.isLrt,
    required this.isKrl,
    required this.isMrt,
    required this.isAccessible,
    this.operationalCode,
    this.lineInfo,
    this.statusText,
    this.statusColor,
    this.publicCodes = const [],
  });

  final String id;
  final String slug;
  final String name;
  final String shortName;
  final String? operationalCode;
  final String? lineInfo;
  final String? statusText;
  final String? statusColor;
  final bool isLrt;
  final bool isKrl;
  final bool isMrt;
  final bool isAccessible;
  final List<String> publicCodes;

  String get codes => publicCodes.join(' / ');
  String get services =>
      [if (isKrl) 'KRL', if (isMrt) 'MRT', if (isLrt) 'LRT'].join(' · ');
}
