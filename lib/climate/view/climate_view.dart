import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../styles.dart';
import '../model/climate_row.dart';
import '../controller/climate_controller.dart';

class ClimateView extends GetView<ClimateController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: controller.pickAndParseFile,
            tooltip: 'Upload CSV/Excel',
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: double.infinity,
            child: Table(
              border: TableBorder.all(color: Colors.grey, width: 0.5),
              defaultColumnWidth: FlexColumnWidth(),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: columnHeaderBg),
                  children: [
                    TableCell(
                      child: Text(
                        'Month',
                        textAlign: TextAlign.center,
                        style: columnHeaderStyle,
                      ),
                    ),
                    ...controller.columns.map(
                      (col) => TableCell(
                        child: Text(
                          col,
                          textAlign: TextAlign.center,
                          style: columnHeaderStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                ...List.generate(controller.months.length, (rowIdx) {
                  ClimateRow? row =
                      controller.climateRows.isNotEmpty && rowIdx < controller.climateRows.length
                          ? controller.climateRows[rowIdx]
                          : null;
                  return TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          color: rowHeaderBg,
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            controller.months[rowIdx],
                            textAlign: TextAlign.center,
                            style: rowHeaderStyle,
                          ),
                        ),
                      ),
                      ...List.generate(controller.columns.length, (colIdx) {
                        if (colIdx == controller.columns.length - 1) {
                          String etoStr = row?.eto ?? '';
                          return TableCell(
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              color: Colors.yellow.withAlpha(100),
                              child: Text(etoStr, textAlign: TextAlign.center),
                            ),
                          );
                        }
                        String value = row?.getValue(colIdx) ?? '';
                        return TableCell(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color:
                                colIdx > 4
                                    ? Colors.yellow.withAlpha(100)
                                    : Colors.transparent,
                            child: Text(value, textAlign: TextAlign.center),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
