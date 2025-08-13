import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/soil_data.dart';
import '../controller/soil_controller.dart';

class SoilView extends GetView<SoilController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: controller.pickAndParseFile,
            tooltip: 'Upload Excel',
          ),
        ],
      ),
      body: Obx(() {
        final soil = controller.soilData.value;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                readOnly: true,
                controller: TextEditingController(text: soil?.soilName ?? ''),
                decoration: InputDecoration(
                  labelText: 'Soil Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: soil?.fieldCapacity.toString() ?? ''),
                decoration: InputDecoration(
                  labelText: 'Field Capacity (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.updateField(fieldCapacity: double.tryParse(value)),
              ),
              SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: soil?.wiltingPoint.toString() ?? ''),
                decoration: InputDecoration(
                  labelText: 'Wilting Point (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.updateField(wiltingPoint: double.tryParse(value)),
              ),
              SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: soil?.rootzoneDepth.toString() ?? ''),
                decoration: InputDecoration(
                  labelText: 'Effective Rootzone Depth (mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.updateField(rootzoneDepth: double.tryParse(value)),
              ),
              SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: soil?.taw.toStringAsFixed(2) ?? ''),
                decoration: InputDecoration(
                  labelText: 'Total Available Water (TAW, mm)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: soil?.raw.toStringAsFixed(2) ?? ''),
                decoration: InputDecoration(
                  labelText: 'Readily Available Water (RAW, mm)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: soil?.moistureDepletion.toString() ?? ''),
                decoration: InputDecoration(
                  labelText: 'Available Soil Moisture Depletion (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.updateField(moistureDepletion: double.tryParse(value)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
