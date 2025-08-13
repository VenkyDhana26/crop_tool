import 'dart:math';

// Data model for a climate row. ETo calculation is handled by the controller.
class ClimateRow {
  final String month;
  final List<double> values; // [Min Temp, Max Temp, Humidity, Wind, Sun, Rad]
  final String eto; // Store calculated ETo as string for display

  ClimateRow({required this.month, required this.values, required this.eto});

  String getValue(int idx) {
    if (idx < values.length) {
      return values[idx].toStringAsFixed(2);
    }
    return '';
  }

  // Remove getETo and minETo from here; move calculation to controller
} 