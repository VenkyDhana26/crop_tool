import 'package:flutter/material.dart';

class ScheduleView extends StatefulWidget {
  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule View')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Fields
            TextFormField(
              decoration: InputDecoration(labelText: 'ETo station'),
            ),
            TextFormField(decoration: InputDecoration(labelText: 'Crop')),
            TextFormField(
              decoration: InputDecoration(labelText: 'Planting date'),
            ),
            // Checkboxes
            CheckboxListTile(
              title: Text('Irrigation schedule'),
              value: true,
              onChanged: (bool? value) {},
            ),
            CheckboxListTile(
              title: Text('Daily soil moisture balance'),
              value: false,
              onChanged: (bool? value) {},
            ),
            // Table
            DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Day')),
                DataColumn(label: Text('Stage')),
                DataColumn(label: Text('Rain')),
                DataColumn(label: Text('Kc')),
                DataColumn(label: Text('Eta')),
                DataColumn(label: Text('Depl')),
                DataColumn(label: Text('Net Ir')),
                DataColumn(label: Text('Deficit')),
                DataColumn(label: Text('Loss')),
                DataColumn(label: Text('Gr. Ir')),
                DataColumn(label: Text('Flow')),
              ],
              rows: const <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                  ],
                ),
              ],
            ),
            // Calculated Values
            Text('Actual water use by crop: mm'),
            Text('Potential water use by crop: mm'),
            Text('Moist deficit at harvest: mm'),
          ],
        ),
      ),
    );
  }
}
