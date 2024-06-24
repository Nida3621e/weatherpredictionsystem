import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sparkline/sparkline.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GaussianDistributed extends StatefulWidget {
  @override
  _GaussianDistributedState createState() => _GaussianDistributedState();
}

class _GaussianDistributedState extends State<GaussianDistributed> {
  String _city = 'Karachi';
  double _averageTemperature = 0.0;
  List<double> _temperatureHistory = [];
  List<double> _sevenDaysWeather = [];
  double _latitude = 24.8608;
  double _longitude = 67.0104;
  dynamic _currentTemperature = 0.0;
  double _historicalMean = 0.0;
  double _historicalStdDev = 0.0;

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final apiUrl =
        'https://archive-api.open-meteo.com/v1/archive?latitude=24.8608&longitude=67.0104&start_date=2022-01-01&end_date=2023-12-31&daily=temperature_2m_max';
    final apiUrl2 =
        'https://api.open-meteo.com/v1/forecast?latitude=$_latitude&longitude=$_longitude&current=temperature_2m';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> temperatures =
            jsonData['daily']['temperature_2m_max'];
        double sum = 0.0;

        temperatures.forEach((temp) {
          sum += temp;
        });

        double mean = sum / temperatures.length;
        double variance = temperatures
                .map((temp) => pow(temp - mean, 2))
                .reduce((a, b) => a + b) /
            temperatures.length;
        double stdDev = sqrt(variance);

        setState(() {
          _averageTemperature = mean.ceilToDouble();
          _temperatureHistory =
              temperatures.map<double>((temp) => temp.toDouble()).toList();
          _historicalMean = mean.ceilToDouble();
          _historicalStdDev = stdDev.ceilToDouble();
          print(variance);
          print(_historicalMean);
          print(_historicalStdDev);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
    try {
      final response = await http.get(Uri.parse(apiUrl2));
      if (response.statusCode == 200) {
        final jsonData1 = json.decode(response.body);
        final dynamic current = jsonData1['current']['temperature_2m'];

        setState(() {
          _currentTemperature = current;
        });
      } else {
        throw Exception('Failed to load weather data 2');
      }
    } catch (e) {
      print('Error fetching weather data 2: $e');
    }
  }

  final Random _random = Random();

  double _generateRandomNormal() {
    double u1 = 1.0 - _random.nextDouble(); // Convert [0, 1) to (0, 1]
    double u2 = 1.0 - _random.nextDouble();
    double standardNormal = sqrt(-2.0 * log(u1)) *
        cos(2.0 * pi * u2); // Standard normal distribution
    return standardNormal;
  }

  // Simulate temperature based on historical data using standard deviation
  double simulateTemperature(double currentTemp, double stdDev) {
    double randomValue = _generateRandomNormal();
    return currentTemp + randomValue * stdDev;
  }

  // Run multiple simulations
  List<double> runSimulations(
      double currentTemp, int simulationsCount, double stdDev) {
    List<double> results = [];
    for (int i = 0; i < simulationsCount; i++) {
      results.add(simulateTemperature(currentTemp, stdDev));
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_latitude, _longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'City: $_city',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Average Temperature: ${_averageTemperature} °C',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _temperatureHistory.isNotEmpty
                  ? LineChart(LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots:
                              _temperatureHistory.asMap().entries.map((entry) {
                            return FlSpot(
                                entry.key.toDouble(), entry.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      // minX: 0,
                      maxX: _temperatureHistory.length.toDouble() - 1,
                      // minY: 25,
                      // maxY:15;
                    ))
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            Text("Predicted: $_sevenDaysWeather"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                List<double> simulatedTemperatures = [];
                _sevenDaysWeather = [];
                for (int i = 0; i < 7; i++) {
                  double sum = 0.0;
                  simulatedTemperatures = runSimulations(
                      _currentTemperature, 100, _historicalStdDev);
                  for (int j = 0; j < simulatedTemperatures.length; j++) {
                    sum += simulatedTemperatures[j];
                  }
                  _currentTemperature = (sum / simulatedTemperatures.length);
                  _sevenDaysWeather.add(double.parse(
                      (sum / simulatedTemperatures.length).toStringAsFixed(2)));
                }
                // _dialog(_sevenDaysWeather,DateTime.now().day);
                setState(() {
                  _temperatureHistory = _sevenDaysWeather;
                  // _sevenDaysWeather = [];
                });
              },
              child: Text('Run Monte Carlo Simulation'),
            ),
          ],
        ),
      ),
    );
  }
  void _dialog(List<double> sevenDays,int dayNumber) {
    String getDayName(int dayNumber) {
      DateTime date = DateTime(2024, 6, dayNumber); // Use any year and month
      return DateFormat('EEEE').format(date); // 'EEEE' gives full day name
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Text('7 Days Weather Prediction:',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
              SizedBox(height: 20),
              for (int i = 0; i < sevenDays.length; i++)
                Text(getDayName(dayNumber=dayNumber+1)+': \t\t\t${sevenDays[i]} °C'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

}
