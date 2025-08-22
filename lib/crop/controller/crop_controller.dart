import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import '../model/crop_data.dart';
import '../../global_data_store.dart';

class CropController extends GetxController {
  var selectedDate = Rxn<DateTime>(DateTime.now());
  var cropName = ''.obs;
  var cropData = <CropStageData>[].obs;
  var isDataLoaded = false.obs;

  final List<String> staticStages = [
    'Initial',
    'Development',
    'Mid season',
    'Late season',
    'Harvest',
  ];

  final Map<String, double> kcbValues = {
    'Initial': 0.15,
    'Development': 0.15,
    'Mid season': 1.15,
    'Late season': 0.45,
    'Harvest': 0.0,
  };

  final Map<String, Map<String, double>> cropKcbValues = {
    'Broccoli': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Brussel Sprouts': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Cabbage': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Carrots': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Cauliflower': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Celery': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.90,
      'Harvest': 0.0,
    },
    'Garlic': {
      'Initial': 0.15,
      'Mid season': 0.90,
      'Late season': 0.60,
      'Harvest': 0.0,
    },
    'Lettuce': {
      'Initial': 0.15,
      'Mid season': 0.90,
      'Late season': 0.90,
      'Harvest': 0.0,
    },
    'Onions - dry': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.65,
      'Harvest': 0.0,
    },
    'Onions - green': {
      'Initial': 0.15,
      'Mid season': 0.90,
      'Late season': 0.90,
      'Harvest': 0.0,
    },
    'Onions - seed': {
      'Initial': 0.15,
      'Mid season': 1.05,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Spinach': {
      'Initial': 0.15,
      'Mid season': 0.90,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Radishes': {
      'Initial': 0.15,
      'Mid season': 0.85,
      'Late season': 0.75,
      'Harvest': 0.0,
    },
    'EggPlant': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.80,
      'Harvest': 0.0,
    },
    'Sweet Peppers (bell)': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.80,
      'Harvest': 0.0,
    },
    'Tomato': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Cantaloupe': {
      'Initial': 0.15,
      'Mid season': 0.75,
      'Late season': 0.50,
      'Harvest': 0.0,
    },
    'Cucumber - Fresh Market': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Cucumber - Machine harvest': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.80,
      'Harvest': 0.0,
    },
    'Pumpkin': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Winter Squash': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Squash, Zucchini': {
      'Initial': 0.15,
      'Mid season': 0.90,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Sweet Melons': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Watermelon': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Beets, table': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Cassava - year 1': {
      'Initial': 0.15,
      'Mid season': 0.70,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Cassava - year 2': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.45,
      'Harvest': 0.0,
    },
    'Parsnip': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Potato': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.65,
      'Harvest': 0.0,
    },
    'Sweet Potato': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.55,
      'Harvest': 0.0,
    },
    'Turnip': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Rutabaga': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.85,
      'Harvest': 0.0,
    },
    'Sugar Beet': {
      'Initial': 0.15,
      'Mid season': 1.15,
      'Late season': 0.50,
      'Harvest': 0.0,
    },
    'Beans, green': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.80,
      'Harvest': 0.0,
    },
    'Beans, dry and Pulses': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.25,
      'Harvest': 0.0,
    },
    'Chick pea': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.25,
      'Harvest': 0.0,
    },
    'Fababean - Fresh': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 1.05,
      'Harvest': 0.0,
    },
    'Fababean - Dry/Seed': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Grabanzo': {
      'Initial': 0.15,
      'Mid season': 1.05,
      'Late season': 0.25,
      'Harvest': 0.0,
    },
    'Green Gram and Cowpeas': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.40,
      'Harvest': 0.0,
    },
    'Groundnut (Peanut)': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.50,
      'Harvest': 0.0,
    },
    'Lentil': {
      'Initial': 0.15,
      'Mid season': 1.05,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Peas - Fresh': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 1.05,
      'Harvest': 0.0,
    },
    'Peas - Dry/Seed': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Soybeans': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.30,
      'Harvest': 0.0,
    },
    'Artichokes': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.90,
      'Harvest': 0.0,
    },
    'Asparagus': {
      'Initial': 0.15,
      'Mid season': 0.90,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Mint': {
      'Initial': 0.40,
      'Mid season': 1.10,
      'Late season': 1.05,
      'Harvest': 0.0,
    },
    'Strawberries': {
      'Initial': 0.30,
      'Mid season': 0.80,
      'Late season': 0.70,
      'Harvest': 0.0,
    },
    'Cotton': {
      'Initial': 0.15,
      'Mid season': 1.13,
      'Late season': 0.45,
      'Harvest': 0.0,
    },
    'Flax': {
      'Initial': 0.15,
      'Mid season': 1.05,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Sisal': {
      'Initial': 0.15,
      'Mid season': 0.55,
      'Late season': 0.55,
      'Harvest': 0.0,
    },
    'Castorbean': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.45,
      'Harvest': 0.0,
    },
    'Rapeseed, Canola': {
      'Initial': 0.15,
      'Mid season': 1.02,
      'Late season': 0.25,
      'Harvest': 0.0,
    },
    'Safflower': {
      'Initial': 0.15,
      'Mid season': 1.02,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Sesame': {
      'Initial': 0.15,
      'Mid season': 1.05,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Sunflower': {
      'Initial': 0.15,
      'Mid season': 1.02,
      'Late season': 0.25,
      'Harvest': 0.0,
    },
    'Barley': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.15,
      'Harvest': 0.0,
    },
    'Oats': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.15,
      'Harvest': 0.0,
    },
    'Spring Wheat': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.15,
      'Harvest': 0.0,
    },
    'Winter Wheat': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 0.15,
      'Harvest': 0.0,
    },
    'Maize - Field (grain)': {
      'Initial': 0.15,
      'Mid season': 1.15,
      'Late season': 0.33,
      'Harvest': 0.0,
    },
    'Maize - Sweet': {
      'Initial': 0.15,
      'Mid season': 1.10,
      'Late season': 1.00,
      'Harvest': 0.0,
    },
    'Millet': {
      'Initial': 0.15,
      'Mid season': 0.95,
      'Late season': 0.20,
      'Harvest': 0.0,
    },
    'Sorghum - grain': {
      'Initial': 0.15,
      'Mid season': 1.00,
      'Late season': 0.35,
      'Harvest': 0.0,
    },
    'Sorghum - sweet': {
      'Initial': 0.15,
      'Mid season': 1.15,
      'Late season': 1.00,
      'Harvest': 0.0,
    },
    'Rice': {
      'Initial': 1.00,
      'Mid season': 1.15,
      'Late season': 0.58,
      'Harvest': 0.0,
    },
  };

  Map<String, double> getKcbValuesForCrop(String cropName) {
    if (cropKcbValues.containsKey(cropName)) {
      return cropKcbValues[cropName]!;
    }
    return kcbValues;
  }

  double getKcbValue(String stage, String cropName) {
    Map<String, double> cropValues = getKcbValuesForCrop(cropName);
    return cropValues[stage] ?? 0.0;
  }

  double calculateKc(
    double kcbTab,
    double cropHeight, {
    double u2 = 4,
    double rhMin = 60,
  }) {
    if (cropHeight <= 0) return kcbTab;
    double adjustment =
        (0.04 * (u2 - 2) - 0.004 * (rhMin - 45)) *
        pow(((cropHeight / 100.0) / 3), 0.3);
    var kcb = kcbTab + adjustment;
    var kcMin = 1.2 + (0.04 * (u2 - 2) - 0.004 * (rhMin - 45)) * pow((cropHeight / 3), 0.3);
    var kcMax = max(kcMin, kcb + 0.05);

    return double.parse(kcMax.toStringAsFixed(3));
  }

  Future<void> pickAndParseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );
    if (result != null && result.files.single.bytes != null) {
      Uint8List fileBytes = result.files.single.bytes!;
      String? extension = result.files.single.extension;
      List<List<String>> parsedData = [];
      if (extension == 'csv') {
        String csvString = utf8.decode(fileBytes);
        List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);
        parsedData =
            csvTable
                .map((row) => row.map((e) => e.toString()).toList())
                .toList();
      } else if (extension == 'xlsx') {
        var excel = Excel.decodeBytes(fileBytes);
        for (var table in excel.tables.keys) {
          parsedData =
              excel.tables[table]!.rows
                  .map(
                    (row) =>
                        row
                            .map((cell) => cell?.value?.toString() ?? '')
                            .toList(),
                  )
                  .toList();
          break;
        }
      }
      // Extract crop name from file name
      String cropName = '';
      if (result.files.single.name.isNotEmpty) {
        String fileName = result.files.single.name;
        // Remove file extension
        cropName = fileName.replaceAll(RegExp(r'\.(csv|xlsx)$'), '');
        // Clean up the name (remove any special characters, underscores, etc.)
        cropName = cropName.replaceAll(RegExp(r'[_-]'), ' ').trim();
      }

      // Find the kcb column index
      int kcbColumnIndex = -1;
      if (parsedData.isNotEmpty) {
        for (int i = 0; i < parsedData[0].length; i++) {
          if (parsedData[0][i].trim().toLowerCase() == 'kcb') {
            kcbColumnIndex = i;
            break;
          }
        }
      }

      if (parsedData.isNotEmpty) {
        parsedData = parsedData.skip(1).toList();
      }

      List<CropStageData> newData = [];
      for (int i = 0; i < staticStages.length; i++) {
        String stage = staticStages[i];
        int duration = 0;
        double cropHeight = 0.0;
        double kcb = 0.0;
        double rootzoneDepth = 0.0;

        for (int j = 0; j < parsedData.length; j++) {
          final row = parsedData[j];
          if (row.length >= 3) {
            if (row[0].trim().toLowerCase() == 'stages') continue;
            String rowStage = row[0].trim().toLowerCase();
            String targetStage = stage.toLowerCase();
            bool isMatch = false;
            if (rowStage == targetStage) {
              isMatch = true;
            } else if (targetStage == 'mid season' &&
                (rowStage == 'mid' || rowStage == 'mid-season')) {
              isMatch = true;
            } else if (targetStage == 'late season' &&
                (rowStage == 'late' || rowStage == 'late-season')) {
              isMatch = true;
            }
            if (isMatch) {
              duration = int.tryParse(row[1].trim()) ?? 0;
              cropHeight = (double.tryParse(row[2].trim()) ?? 0.0) / 100;
              rootzoneDepth = double.tryParse(row[4].trim()) ?? 0.0;

              // Get kcb value from the kcb column if it exists
              if (kcbColumnIndex >= 0 && kcbColumnIndex < row.length) {
                kcb = double.tryParse(row[kcbColumnIndex].trim()) ?? 0.0;
              } else {
                // Fallback to local mapping if kcb column not found
                kcb = getKcbValue(stage, cropName);
              }
              break;
            }
          }
        }

        double kc = calculateKc(kcb, cropHeight);
        
        // Default rootzone depth values for each stage (in cm)
        
       
        newData.add(
          CropStageData(
            stage: stage,
            duration: duration,
            cropHeight: cropHeight,
            kcbValue: kcb,
            kc: kc,
            rootzoneDepth: rootzoneDepth,
          ),
        );
      }
      this.cropData.assignAll(newData);
      this.cropName.value = cropName;
      this.isDataLoaded.value = true;

      // Update global data store with crop stage data
      GlobalDataStore.updateCropStageData(newData);
    }
  }

  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }
}
