import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../styles.dart';
import '../model/crop_data.dart';
import '../controller/crop_controller.dart';

class CropView extends GetView<CropController> {
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(text: controller.cropName.value),
                      decoration: InputDecoration(
                        labelText: 'Crop Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          controller.setSelectedDate(pickedDate);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: controller.selectedDate.value != null
                                ? '${controller.selectedDate.value!.day.toString().padLeft(2, '0')}/'
                                  '${controller.selectedDate.value!.month.toString().padLeft(2, '0')}/'
                                  '${controller.selectedDate.value!.year}'
                                : '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Planting Date',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Table(
                    border: TableBorder.all(color: Colors.grey, width: 0.5),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: columnHeaderBg),
                        children: [
                          TableCell(
                            child: Text(
                              'Stage',
                              textAlign: TextAlign.center,
                              style: columnHeaderStyle,
                            ),
                          ),
                          TableCell(
                            child: Text(
                              'Duration (days)',
                              textAlign: TextAlign.center,
                              style: columnHeaderStyle,
                            ),
                          ),
                          TableCell(
                            child: Text(
                              'Crop height (m)',
                              textAlign: TextAlign.center,
                              style: columnHeaderStyle,
                            ),
                          ),
                          TableCell(
                            child: Text(
                              'Kc value',
                              textAlign: TextAlign.center,
                              style: columnHeaderStyle,
                            ),
                          ),
                        ],
                      ),
                      ...controller.cropData.map((data) {
                        return TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                color: rowHeaderBg,
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  data.stage,
                                  textAlign: TextAlign.center,
                                  style: rowHeaderStyle,
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  data.duration.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  data.cropHeight.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  data.kc?.toString() ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
