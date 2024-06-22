import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sparkline/sparkline.dart';

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
      home: WeatherForecastPage(),
    );
  }
}

class WeatherForecastPage extends StatefulWidget {
  @override
  _WeatherForecastPageState createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  String _city = 'Berlin';
  double _averageTemperature = 0.0;
  List<double> _temperatureHistory = [];
  double _latitude = 52.52;
  double _longitude = 13.41;

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final apiUrl =
        'https://archive-api.open-meteo.com/v1/archive?latitude=$_latitude&longitude=$_longitude&start_date=2010-01-01&end_date=2019-12-31&hourly=temperature_2m';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> temperatures = jsonData['hourly']['temperature_2m'];
        double sum = 0.0;

        temperatures.forEach((temp) {
          sum += temp;
        });

        setState(() {
          _averageTemperature = sum / temperatures.length;
          _temperatureHistory = temperatures.map<double>((temp) => temp.toDouble()).toList();
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  List<double> _runMonteCarloSimulation(List<double> historicalTemperatures, int numSimulations) {
    final random = Random();
    final temperatures = <double>[];

    for (int i = 0; i < numSimulations; i++) {
      final randomIndex = random.nextInt(historicalTemperatures.length);
      final baseTemperature = historicalTemperatures[randomIndex];
      final variation = random.nextDouble() * 10 - 5; // Random variation between -5 and 5
      final simulatedTemperature = baseTemperature + variation;
      temperatures.add(simulatedTemperature);
    }

    return temperatures;
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
              'Average Temperature: ${_averageTemperature.toStringAsFixed(1)} °C',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _temperatureHistory.isNotEmpty
                  ? Sparkline(
                data: _temperatureHistory,
                lineWidth: 3.0,
                lineColor: Colors.blue,
                pointsMode: PointsMode.all,
                pointSize: 8.0,
              )
                  : Center(
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final simulatedTemperatures = _runMonteCarloSimulation(_temperatureHistory, 30);
                setState(() {
                  _temperatureHistory = simulatedTemperatures;
                });
              },
              child: Text('Run Monte Carlo Simulation'),
            ),
          ],
        ),
      ),
    );
  }
}
