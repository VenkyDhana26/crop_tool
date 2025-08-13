import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import '../model/soil_data.dart';

class SoilController extends GetxController {
  var soilData = Rxn<SoilData>();

  Future<void> pickAndParseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );
    if (result != null && result.files.single.bytes != null) {
      Uint8List fileBytes = result.files.single.bytes!;
      String? extension = result.files.single.extension;
      List<String> parsedData = [];
      if (extension == 'csv') {
        String csvString = utf8.decode(fileBytes);
        List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);
        for (int i = 0; i < csvTable.length; i++) {
          if (csvTable[i].isNotEmpty) {
            String value = csvTable[i][0].toString();
            parsedData.add(value);
          }
        }
      } else if (extension == 'xlsx') {
        var excel = Excel.decodeBytes(fileBytes);
        for (var table in excel.tables.keys) {
          var rows = excel.tables[table]!.rows;
          if (rows.isNotEmpty) {
            for (int i = 0; i < rows.length; i++) {
              if (rows[i].isNotEmpty && rows[i][1] != null) {
                String value = rows[i][1]!.value.toString();
                parsedData.add(value);
              }
            }
          }
          break;
        }
      }
      String soilName = parsedData.length > 0 ? parsedData[0] : '';
      double fieldCapacity = double.tryParse(parsedData.length > 1 ? parsedData[1] : '') ?? 0.0;
      double wiltingPoint = double.tryParse(parsedData.length > 2 ? parsedData[2] : '') ?? 0.0;
      double rootzoneDepth = double.tryParse(parsedData.length > 3 ? parsedData[3] : '') ?? 0.0;
      double moistureDepletion = double.tryParse(parsedData.length > 4 ? parsedData[4] : '') ?? 0.0;
      soilData.value = SoilData.fromFields(
        soilName: soilName,
        fieldCapacity: fieldCapacity,
        wiltingPoint: wiltingPoint,
        rootzoneDepth: rootzoneDepth,
        moistureDepletion: moistureDepletion,
      );
    }
  }

  void updateField({String? soilName, double? fieldCapacity, double? wiltingPoint, double? rootzoneDepth, double? moistureDepletion}) {
    final current = soilData.value;
    if (current == null) return;
    soilData.value = SoilData.fromFields(
      soilName: soilName ?? current.soilName,
      fieldCapacity: fieldCapacity ?? current.fieldCapacity,
      wiltingPoint: wiltingPoint ?? current.wiltingPoint,
      rootzoneDepth: rootzoneDepth ?? current.rootzoneDepth,
      moistureDepletion: moistureDepletion ?? current.moistureDepletion,
    );
  }
}
