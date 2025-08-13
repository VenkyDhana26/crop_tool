import 'package:get/get.dart';
import '../../global_data_store.dart';
import '../../crop/controller/crop_controller.dart';
import '../../soil/controller/soil_controller.dart';
import '../../climate/controller/climate_controller.dart';
import '../../climate/model/precipitation_helper.dart';

class CropWaterRequirementController extends GetxController {
  final CropController cropController = Get.find<CropController>();
  final SoilController soilController = Get.find<SoilController>();
  final ClimateController climateController = Get.find<ClimateController>();

  // Observable variables
  var cropName = ''.obs;
  var plantingDate = Rxn<DateTime>();
  var cropStageData = <dynamic>[].obs;
  var stageRowCounts = <int>[4, 4, 4, 4, 4].obs;
  var rowDates = <DateTime>[].obs;
  var etoValues = <double>[].obs;
  var kcCoefValues = <double>[].obs;
  var rainValues = <String>[].obs;
  var effectiveRainValues = <String>[].obs; // Peff (mm/day)
  var irrValues = <String>[].obs; // IRR (mm/day) = ETc - Peff

  @override
  void onInit() {
    super.onInit();
    _assignValues();

    // Listen to changes in crop controller
    ever(cropController.cropName, (_) => _assignValues());
    ever(cropController.selectedDate, (_) => _assignValues());

    // Listen to changes in global data store
    ever(GlobalDataStore.cropStageData.obs, (_) => _assignValues());

    // Listen to changes in soil controller
    ever(soilController.soilData, (_) => _assignValues());
  }

  void _assignValues() {
    cropName.value = cropController.cropName.value;
    plantingDate.value = cropController.selectedDate.value;
    cropStageData.assignAll(GlobalDataStore.cropStageData);
    _calculateStageRowCounts();
    _calculateRowDates();
    _calculateKcCoefValues();
    _calculateEtoValues();
    _calculateRainValues();
    _calculateEffectiveRainValues();
    _calculateIrrValues();
  }

  // Calculate rows for each stage based on cumulative duration
  void _calculateStageRowCounts() {
    List<int> rowCounts = [];

    if (cropStageData.isEmpty) {
      // Default values if no data is loaded
      stageRowCounts.assignAll([4, 4, 4, 4, 4]);
      return;
    }

    int previousDuration = 0;
    for (int i = 0; i < cropStageData.length; i++) {
      int currentDuration = cropStageData[i].duration;
      int stageRows = currentDuration - previousDuration;
      rowCounts.add(stageRows);
      previousDuration = currentDuration;
    }

    stageRowCounts.assignAll(rowCounts);
  }

  // Calculate dates for each row based on planting date and stage durations
  void _calculateRowDates() {
    List<DateTime> dates = [];

    if (plantingDate.value == null || cropStageData.isEmpty) {
      rowDates.assignAll(dates);
      return;
    }

    DateTime currentDate = plantingDate.value!;

    for (int stageIndex = 0; stageIndex < cropStageData.length; stageIndex++) {
      int rowCount =
          stageRowCounts.length > stageIndex ? stageRowCounts[stageIndex] : 4;

      for (int rowIdx = 0; rowIdx < rowCount; rowIdx++) {
        dates.add(currentDate);
        currentDate = currentDate.add(Duration(days: 1));
      }
    }

    rowDates.assignAll(dates);
  }

  // Calculate ETo values for each row based on dates
  void _calculateEtoValues() {
    List<double> etoList = [];

    if (rowDates.isEmpty || climateController.climateRows.isEmpty) {
      etoValues.assignAll(etoList);
      return;
    }

    for (DateTime date in rowDates) {
      double etoValue = _getEtoForDate(date);
      var coEff = kcCoefValues[rowDates.indexOf(date)];
      etoList.add(etoValue * coEff);
    }

    etoValues.assignAll(etoList);
  }

  // Get ETo value for a specific date
  double _getEtoForDate(DateTime date) {
    // Find the month for the given date
    String monthName = _getMonthName(date.month);

    // Find the climate row for this month
    for (var climateRow in climateController.climateRows) {
      if (climateRow.month.toLowerCase() == monthName.toLowerCase()) {
        // Calculate day of year (J value)
        int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

        // Use the climate data to calculate ETo for this specific day
        if (climateRow.values.length >= 5) {
          return _calculateEtoForDay(climateRow.values, dayOfYear);
        }
      }
    }

    return 0.0; // Default value if no climate data found
  }

  // Calculate ETo for a specific day using climate data
  double _calculateEtoForDay(List<double> climateValues, int dayOfYear) {
    // Extract climate data
    double Tmin = climateValues[0]; // Min Temperature
    double Tmax = climateValues[1]; // Max Temperature
    double RH = climateValues[2]; // Relative Humidity
    double u2 = climateValues[3]; // Wind Speed (km/day)
    double Rs = climateValues[4]; // Solar Radiation (MJ/m²/hrs)

    // Call the climate controller's calculateETo method with the specific day
    String etoString = climateController.calculateETo(
      'Custom',
      climateValues,
      J: dayOfYear,
    );
    return double.tryParse(etoString) ?? 0.0;
  }

  // Calculate Kc coefficients for each row
  void _calculateKcCoefValues() {
    List<double> kcList = [];
    final cropData = cropController.cropData;
    List<int> stageStartIndices = [];
    List<double> stageKcValues = [];
    int runningIndex = 0;
    for (int i = 0; i < stageRowCounts.length; i++) {
      stageStartIndices.add(runningIndex + 1); // 1-based
      double kc =
          (i < cropData.length && cropData[i].kc != null)
              ? cropData[i].kc!
              : 0.0;
      stageKcValues.add(kc);
      runningIndex += stageRowCounts[i];
    }
    int totalRows = runningIndex;
    for (
      int globalRowIndex = 0, stageIndex = 0, subRowIdx = 0;
      globalRowIndex < totalRows;
      globalRowIndex++
    ) {
      int rowCount = stageRowCounts[stageIndex];
      int x = globalRowIndex + 1; // 1-based
      double kcValue = 0.0;
      if (subRowIdx == 0 || stageIndex == stageKcValues.length - 1) {
        kcValue = stageKcValues[stageIndex];
      } else {
        double y1 = stageKcValues[stageIndex];
        double y2 = stageKcValues[stageIndex + 1];
        int x1 = stageStartIndices[stageIndex];
        int x2 = stageStartIndices[stageIndex + 1];
        kcValue = y1 + ((x - x1) * (y2 - y1)) / (x2 - x1);
      }
      kcList.add(kcValue);
      subRowIdx++;
      if (subRowIdx >= rowCount) {
        stageIndex++;
        subRowIdx = 0;
      }
    }
    kcCoefValues.assignAll(kcList);
  }

  // Calculate rain values for each row
  void _calculateRainValues() {
    List<String> rainList = [];

    if (rowDates.isEmpty) {
      rainValues.assignAll(rainList);
      return;
    }

    for (DateTime date in rowDates) {
      String rainValue = _getRainForDate(date);
      rainList.add(rainValue);
    }

    rainValues.assignAll(rainList);
  }

  // Get rain value for a specific date
  String _getRainForDate(DateTime date) {
    try {
      double? precipitation = PrecipitationHelper.getPrecipitationForDate(date);
      if (precipitation != null) {
        // Convert from mm to cm (1 cm = 10 mm)
        double rainCm = precipitation / 10.0;
        return rainCm.toStringAsFixed(2);
      } else {
        return '0.00'; // Default value if no precipitation data
      }
    } catch (e) {
      return '0.00'; // Default value if error occurs
    }
  }

  // Calculate Effective Rainfall (mm/day) based on USDA monthly method
  // Peff_month when P_total <= 250 mm:
  //   Peff = P_total * (125 - 0.2 * P_total) / 125
  // Peff_month when P_total > 250 mm:
  //   Peff = 125 + 0.1 * P_total
  // We then distribute the monthly Peff evenly across days in the month
  void _calculateEffectiveRainValues() {
    List<String> peffPerDayList = [];

    if (rowDates.isEmpty) {
      effectiveRainValues.assignAll(peffPerDayList);
      return;
    }

    // Pre-compute monthly Peff/day for all months present in rowDates
    final Map<String, double> monthKeyToPeffPerDay = {};

    for (final date in rowDates) {
      final String key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (monthKeyToPeffPerDay.containsKey(key)) continue;

      final int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      double monthlyTotal = 0.0; // mm
      for (int d = 1; d <= daysInMonth; d++) {
        final daily = PrecipitationHelper.getPrecipitationForDate(
          DateTime(date.year, date.month, d),
        );
        monthlyTotal += daily ?? 0.0;
      }

      double peffMonth; // mm
      if (monthlyTotal <= 250.0) {
        peffMonth = monthlyTotal * ((125.0 - 0.2 * monthlyTotal) / 125.0);
      } else {
        peffMonth = 125.0 + 0.1 * monthlyTotal;
      }

      final double peffPerDay = peffMonth / daysInMonth; // mm/day
      monthKeyToPeffPerDay[key] = peffPerDay;
    }

    // Map back to each row date
    for (final date in rowDates) {
      final String key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final double value = monthKeyToPeffPerDay[key] ?? 0.0;
      peffPerDayList.add(value.toStringAsFixed(2));
    }

    effectiveRainValues.assignAll(peffPerDayList);
  }

  // Calculate IRR (mm/day) = ETc (mm/day) - Effective rainfall (mm/day)
  void _calculateIrrValues() {
    final List<String> irrList = [];

    final int n = rowDates.length;
    for (int i = 0; i < n; i++) {
      final double etc = i < etoValues.length ? etoValues[i] : 0.0;
      final double peff = i < effectiveRainValues.length
          ? double.tryParse(effectiveRainValues[i]) ?? 0.0
          : 0.0;
      final double irr = etc - peff;
      irrList.add(irr.toStringAsFixed(2));
    }

    irrValues.assignAll(irrList);
  }

  // Get month name from month number
  String _getMonthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
