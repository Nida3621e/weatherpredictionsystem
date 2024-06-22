import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sparkline/sparkline.dart';

class NormalDistributed extends StatefulWidget {
  @override
  _NormalDistributedState createState() => _NormalDistributedState();
}

class _NormalDistributedState extends State<NormalDistributed> {
  String _city = 'Karachi';
  double _averageTemperature = 0.0;
  List<double> _temperatureHistory = [];
  List<double> sevendays=[];
  List<double> currentTemperatures = [];
  List<double> sevenDaysWeather = [];
  double _latitude = 24.8608;
  double _longitude = 67.0104;
  dynamic _currentTemperature = 0.0;

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final apiUrl =
        'https://archive-api.open-meteo.com/v1/archive?latitude=24.8608&longitude=67.0104&start_date=2022-01-01&end_date=2023-12-31&hourly=temperature_2m';
    final apiUrl2 =
        'https://api.open-meteo.com/v1/forecast?latitude=$_latitude&longitude=$_longitude&current=temperature_2m';

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
          _temperatureHistory =
              temperatures.map<double>((temp) => temp.toDouble()).toList();
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
          print(current);
          _currentTemperature=current;
        });
      } else {
        throw Exception('Failed to load weather data 2');
      }
    } catch (e) {
      print('Error fetching weather data 2: $e');
    }
  }

  // List<double> _runMonteCarloSimulation(List<double> historicalTemperatures, int numSimulations) {
  //   final random = Random();
  //   final temperatures = <double>[];
  //
  //   for (int i = 0; i < numSimulations; i++) {
  //     final randomIndex = random.nextInt(historicalTemperatures.length);
  //     final baseTemperature = historicalTemperatures[randomIndex];
  //     final variation = random.nextDouble() * 10 - 5; // Random variation between -5 and 5
  //     final simulatedTemperature = baseTemperature + variation;
  //     temperatures.add(simulatedTemperature);
  //   }
  //
  //   return temperatures;
  // }
  final Random _random = Random();

  // Simulate temperature based on historical data
  double simulateTemperature(double currentTemp) {
    double variance = 5.0; // Define a variance range for temperature changes
    return currentTemp + _random.nextDouble() * variance - variance / 2;
  }

  // Run multiple simulations
  List<double> runSimulations(double currentTemp, int simulationsCount) {
    List<double> results = [];
    for (int i = 0; i < simulationsCount; i++) {
      results.add(simulateTemperature(currentTemp));
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
            Text("Predicted: ${sevenDaysWeather}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                List<double> simulatedTemperatures=[];
                for(int i=0;i<7;i++)
                {
                  double sum=0.0;
                  simulatedTemperatures = runSimulations(_currentTemperature, 20);
                  for (int j = 0; j < simulatedTemperatures.length; j++) {
                    sum += simulatedTemperatures[j];
                  }
                  _currentTemperature = (sum/simulatedTemperatures.length);
                  sevendays.add(sum/simulatedTemperatures.length);
                }

                setState(() {
                  // double total = 0;
                  // for (int i = 0; i < simulatedTemperatures.length; i++) {
                  //   total += simulatedTemperatures[i];
                  // }
                  // double average = total / simulatedTemperatures.length;
                  // currentTemperatures.add(average);

                  sevenDaysWeather=sevendays;
                  // _temperatureHistory = simulatedTemperatures;
                  _temperatureHistory=sevenDaysWeather;
                  sevendays=[];
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
