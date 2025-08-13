class SoilData {
  final String soilName;
  final double fieldCapacity;
  final double wiltingPoint;
  final double rootzoneDepth;
  final double moistureDepletion;
  final double taw;
  final double raw;

  SoilData({
    required this.soilName,
    required this.fieldCapacity,
    required this.wiltingPoint,
    required this.rootzoneDepth,
    required this.moistureDepletion,
    required this.taw,
    required this.raw,
  });

  factory SoilData.fromFields({
    required String soilName,
    required double fieldCapacity,
    required double wiltingPoint,
    required double rootzoneDepth,
    required double moistureDepletion,
  }) {
    final taw = (fieldCapacity - wiltingPoint) * rootzoneDepth * 1.45 / 100;
    final raw = taw * moistureDepletion / 100;
    return SoilData(
      soilName: soilName,
      fieldCapacity: fieldCapacity,
      wiltingPoint: wiltingPoint,
      rootzoneDepth: rootzoneDepth,
      moistureDepletion: moistureDepletion,
      taw: taw,
      raw: raw,
    );
  }
}
