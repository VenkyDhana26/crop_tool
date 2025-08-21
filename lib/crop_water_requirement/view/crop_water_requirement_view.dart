import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../styles.dart';
import '../controller/crop_water_requirement_controller.dart';

class CropWaterRequirementView extends GetView<CropWaterRequirementController> {
  @override
  Widget build(BuildContext context) {
    final List<String> stages = [
      'Initial',
      'Development',
      'Mid season',
      'Late season',
      'Harvest',
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: controller.cropName.value,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Crop',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Obx(
                    () => TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text:
                            controller.plantingDate.value != null
                                ? '${controller.plantingDate.value!.day.toString().padLeft(2, '0')}/'
                                    '${controller.plantingDate.value!.month.toString().padLeft(2, '0')}/'
                                    '${controller.plantingDate.value!.year}'
                                : '',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Planting Date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Obx(() {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildDataTable(
                    context,
                    stages,
                    controller.stageRowCounts,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    List<String> stages,
    List<int> stageRowCounts,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            color: columnHeaderBg,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Stage',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Date',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Container(
                  width: 80.0,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Day',
                    textAlign: TextAlign.center,
                    style: columnHeaderStyle,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Kc coef',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'ETc (mm/day)',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Rain (cm/day)',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Effective rainfall (mm/day)',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Depletion End (mm)',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Net Irrigation Depth (mm)',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Gross Irrigation Depth (mm)',
                      textAlign: TextAlign.center,
                      style: columnHeaderStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data rows
          ..._buildStageRows(stages, stageRowCounts),
        ],
      ),
    );
  }

  List<Widget> _buildStageRows(List<String> stages, List<int> stageRowCounts) {
    List<Widget> rows = [];
    int globalRowIndex = 0;

    for (int stageIndex = 0; stageIndex < stages.length; stageIndex++) {
      int rowCount =
          stageRowCounts.length > stageIndex ? stageRowCounts[stageIndex] : 4;
      for (int subRowIdx = 0; subRowIdx < rowCount; subRowIdx++) {
        // Kc coef value from controller
        String kcValueStr = '';
        if (globalRowIndex < controller.kcCoefValues.length) {
          kcValueStr = controller.kcCoefValues[globalRowIndex].toStringAsFixed(
            3,
          );
        }
        // Date value
        String dateValue = '';
        if (globalRowIndex < controller.rowDates.length) {
          DateTime date = controller.rowDates[globalRowIndex];
          dateValue =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }

        // Day value (sequential number from 1 to n)
        String dayValue = (globalRowIndex + 1).toString();

        // ETo value
        String etoValue = '';
        if (globalRowIndex < controller.etoValues.length) {
          double eto = controller.etoValues[globalRowIndex];
          etoValue = eto > 0 ? eto.toStringAsFixed(5) : '';
        }

        // Rain value from controller
        String rainValue = '';
        if (globalRowIndex < controller.rainValues.length) {
          rainValue = controller.rainValues[globalRowIndex];
        }
        // Effective rainfall (mm/day) from controller
        String effectiveRainValue = '';
        if (globalRowIndex < controller.effectiveRainValues.length) {
          effectiveRainValue = controller.effectiveRainValues[globalRowIndex];
        }
        // IRR (mm/day) from controller = ETc - Effective rainfall
        String irrValue = '';
        if (globalRowIndex < controller.netIrrigationValues.length) {
          irrValue = controller.netIrrigationValues[globalRowIndex];
        }
        // Gross Irrigation Depth (mm/day) from controller
        String grossIrrValue = '';
        if (globalRowIndex < controller.grossIrrigationValues.length) {
          grossIrrValue = controller.grossIrrigationValues[globalRowIndex];
        }
        rows.add(
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: subRowIdx == 0 ? rowHeaderBg : Colors.transparent,
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(4.0),
                    child:
                        subRowIdx == 0
                            ? Text(
                              stages[stageIndex],
                              textAlign: TextAlign.center,
                              style: rowHeaderStyle,
                            )
                            : Text(''),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Text(dateValue, textAlign: TextAlign.center),
                  ),
                ),
                Container(
                  width: 80.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: Text(dayValue, textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Text(kcValueStr, textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Text(etoValue, textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Text(rainValue, textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Text(effectiveRainValue, textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      globalRowIndex < controller.depletionEndValues.length
                          ? controller.depletionEndValues[globalRowIndex].toStringAsFixed(3)
                          : '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    padding: EdgeInsets.all(4.0),
                    child: Text(irrValue, textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32.0,
                    padding: EdgeInsets.all(4.0),
                    child: Text(grossIrrValue, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        );
        globalRowIndex++;
      }
    }
    return rows;
  }
}
