class CropStageData {
  final String stage;
  final int duration;
  final double cropHeight;
  final double? kcValue;
  final double kcbValue;
  final double? kc;
  final double? rootzoneDepth;

  CropStageData({
    required this.stage,
    required this.duration,
    required this.cropHeight,
    required this.kcbValue,
    this.kcValue,
    this.kc, required this.rootzoneDepth,
  });
} 
