import 'package:flutter/material.dart';
import 'blood_pressure_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final List<BloodPressureData> data = [
      BloodPressureData(
        date: "24.12.01",
        systolic: 132,
        diastolic: 91,
        heartRate: 90,
      ),
      BloodPressureData(
        date: "24.12.01",
        systolic: 100,
        diastolic: 70,
        heartRate: 72,
      ),
      BloodPressureData(
        date: "24.12.01",
        systolic: 140,
        diastolic: 90,
        heartRate: 115,
      ),
      BloodPressureData(
        date: "24.12.01",
        systolic: 120,
        diastolic: 100,
        heartRate: 110,
      ),
      BloodPressureData(
        date: "24.12.01",
        systolic: 140,
        diastolic: 100,
        heartRate: 130,
      ),
    ];

    return MaterialApp(
        title: '혈압 차트',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(50),
            child: BloodPressureChart(data: data),
          ),
        ));
  }
}
