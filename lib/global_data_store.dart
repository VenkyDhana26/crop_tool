import '../crop/model/crop_data.dart';

// Global data store for sharing data between views
class GlobalDataStore {
  static String cropName = '';
  static DateTime? plantingDate;
  static int initialStageDuration = 4; // Default value
  static List<CropStageData> cropStageData = [];
  
  static void updateCropData(String name, DateTime? date) {
    cropName = name;
    plantingDate = date;
  }
  
  static void updateInitialStageDuration(int duration) {
    initialStageDuration = duration;
  }
  
  static void updateCropStageData(List<CropStageData> data) {
    cropStageData = data;
    if (data.isNotEmpty) {
      initialStageDuration = data[0].duration;
    }
  }
} 