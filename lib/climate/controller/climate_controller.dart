import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import '../model/climate_row.dart';

class ClimateController extends GetxController {
  var climateRows = <ClimateRow>[].obs;

  final List<String> months = [
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
    'Average',
  ];
  final List<String> columns = [
    'Min Temp (°C)',
    'Max Temp (°C)',
    'Humidity (%)',
    'Wind (km/day)',
    'Solar Radiation (MJ/m²/hrs)',
    'ETo (mm/day)',
  ];

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
          break; // Only use the first sheet
        }
      }

      // Remove the first row (header) and first column (labels) from the uploaded data
      if (parsedData.isNotEmpty) {
        parsedData =
            parsedData
                .skip(1)
                .map(
                  (row) =>
                      row.length > 1
                          ? row.sublist(1).map((e) => e.toString()).toList()
                          : <String>[],
                )
                .toList();
      }

      // Map parsed data to ClimateRow list, using app's month labels
      List<ClimateRow> rows = [];
      for (int i = 0; i < months.length; i++) {
        if (i < parsedData.length) {
          // Parse up to 6 columns as double (ignore extra columns)
          List<double> values = [];
          for (
            int j = 0;
            j < columns.length - 1 && j < parsedData[i].length;
            j++
          ) {
            double? val = double.tryParse(parsedData[i][j]);
            values.add(val ?? 0);
          }
          String eto = calculateETo(months[i], values);
          rows.add(ClimateRow(month: months[i], values: values, eto: eto));
        } else {
          rows.add(ClimateRow(month: months[i], values: [], eto: ''));
        }
      }

      climateRows.assignAll(rows);
    }
  }

  String calculateETo(String month, List<double> values, {int? J}) {
    if (values.length < 5) return '';

    // Extract climate data
    double Tmin = values[0]; // Min Temperature
    double Tmax = values[1]; // Max Temperature
    double RH = values[2]; // Relative Humidity
    double u2 = values[3]; // Wind Speed (km/day)
    double Rs = values[4]; // Solar Radiation (MJ/m²/hrs)

    // Constants
    const double Gsc = 0.0820; // MJ m^-2 min^-1
    const double sigma = 4.903e-9; // MJ K^-4 m^-2 day^-1
    const double albedo = 0.23;
    const double latitudeDeg = 10.79;
    final double latitudeRad = latitudeDeg * pi / 180;
    const double z = 88; // Elevation in meters
    const double Cp = 1.013e-3;
    const double epsilon = 0.622;

    // Atmospheric pressure
    final double P = 101.3 * pow((293 - 0.0065 * z) / 293, 5.26);

    // Use provided J value or calculate from month name
    int jValue;
    if (J != null) {
      jValue = J;
    } else {
      Map<String, Map<String, dynamic>> monthMap = {
        'January': {'name': 'January', 'J': 15},
        'February': {'name': 'February', 'J': 45},
        'March': {'name': 'March', 'J': 75},
        'April': {'name': 'April', 'J': 105},
        'May': {'name': 'May', 'J': 135},
        'June': {'name': 'June', 'J': 165},
        'July': {'name': 'July', 'J': 195},
        'August': {'name': 'August', 'J': 225},
        'September': {'name': 'September', 'J': 255},
        'October': {'name': 'October', 'J': 285},
        'November': {'name': 'November', 'J': 315},
        'December': {'name': 'December', 'J': 345},
        'Average': {'name': 'Average', 'J': 180}, // Mid-year average
      };

      var monthData = monthMap[month]!;
      jValue = monthData['J'];
    }

    // Psychrometric constant
    final double gamma = Cp * P / (0.245 * epsilon);

    // Mean temperature
    final double Tmean = (Tmax + Tmin) / 2;

    // Saturation vapor pressure
    final double esTmax = 0.6108 * exp((17.27 * Tmax) / (Tmax + 237.3));
    final double esTmin = 0.6108 * exp((17.27 * Tmin) / (Tmin + 237.3));
    final double es = (esTmax + esTmin) / 2;

    // Actual vapor pressure
    final double ea = es * RH / 100;

    // Slope of vapor pressure curve
    final double delta =
        4098 *
        (0.6108 * exp((17.27 * Tmean) / (Tmean + 237.3))) /
        pow((Tmean + 237.3), 2);

    // Extraterrestrial radiation
    final double dr = 1 + 0.033 * cos((2 * pi / 365) * jValue);
    final double deltaSun = 0.409 * sin((2 * pi / 365) * jValue - 1.39);
    final double omegaS = acos(-tan(latitudeRad) * tan(deltaSun));

    final double Ra =
        (24 * 60 / pi) *
        Gsc *
        dr *
        (omegaS * sin(latitudeRad) * sin(deltaSun) +
            cos(latitudeRad) * cos(deltaSun) * sin(omegaS));

    // Clear-sky radiation
    final double Rso = (0.75 + 2e-5 * z) * Ra;

    // Net shortwave radiation
    final double Rns = (1 - albedo) * Rs;

    // Net longwave radiation
    final double TmaxK = Tmax + 273.16;
    final double TminK = Tmin + 273.16;

    final double Rnl =
        sigma *
        ((pow(TmaxK, 4) + pow(TminK, 4)) / 2) *
        (0.34 - 0.14 * sqrt(ea)) *
        (1.35 * Rs / Rso - 0.35);

    // Net radiation
    final double Rn = Rns - Rnl;

    // ETo calculation using FAO Penman-Monteith
    final double numerator =
        0.408 * delta * Rn + gamma * (900 / (Tmean + 273)) * u2 * (es - ea);
    final double denominator = delta + gamma * (1 + 0.34 * u2);
    final double ETo = numerator / denominator;

    return ETo.toStringAsFixed(5);
  }
}
