import 'package:flutter/material.dart';
import 'package:weatherpredictionsystems/Dashboard.dart';
import 'package:weatherpredictionsystems/gaussianDistributed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Dashboard(),
    );
  }
}
