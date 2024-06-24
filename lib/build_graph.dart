import 'package:flutter/material.dart';
import 'api_service.dart';
import 'monte_carlo_simulation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'surface_pressure_prediction.dart';

class BuildGraphPage extends StatelessWidget {
  ApiService apiService = ApiService();
  List<double>? predictions;
  String cityName = "Karachi";

  BuildGraphPage({required this.predictions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Prediction for $cityName'),
      ),
      body: predictions == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  getTitlesWidget: (value, meta) => Container(),
                  showTitles: true,
                  reservedSize: 10,
                ),
              ),
              //bottomTitles: SideTitles(showTitles: true, getTitles: (value) => '${value.toInt() + 1}'),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  getTitlesWidget: (value, meta) => Container(),
                  showTitles: true,
                  reservedSize: 10,
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(predictions!.length, (index) => FlSpot(index.toDouble(), predictions![index])),
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
              ),
            ],
          ),
        ),
      ),

    );
  }
}
