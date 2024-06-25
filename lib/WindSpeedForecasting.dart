import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:weatherpredictionsystems/WindDirectionForecasting.dart';  

class WindSpeedForecasting extends StatefulWidget {
  @override
  _WindSpeedForecastingState createState() => _WindSpeedForecastingState();
}

class _WindSpeedForecastingState extends State<WindSpeedForecasting> {
  String _city = 'Karachi';
  double _averageWindSpeed = 0.0;
  List<double> _windSpeedHistory = [];
  List<double> _sevenDaysWindSpeed = [];
  List<String> _nextSevenDays = [];  // List to hold the next 7 days
  double _latitude = 24.8608;
  double _longitude = 67.0104;
  dynamic _currentWindSpeed = 0.0;
  double _historicalMean = 0.0;
  double _historicalStdDev = 0.0;
  bool isLoading = false;

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final apiUrl = 'https://archive-api.open-meteo.com/v1/archive?latitude=$latitude&longitude=$longitude&start_date=2022-01-01&end_date=2023-12-31&hourly=wind_speed_10m';
    final apiUrl2 = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=wind_speed_10m';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData != null && jsonData['hourly'] != null && jsonData['hourly']['wind_speed_10m'] != null) {
          final List<dynamic> windSpeeds = jsonData['hourly']['wind_speed_10m'];
          double sum = 0.0;
          windSpeeds.forEach((speed) {
            sum += speed.toDouble();
          });
          double mean = sum / windSpeeds.length;
          double variance = windSpeeds.map((speed) => pow(speed.toDouble() - mean, 2)).reduce((a, b) => a + b) / windSpeeds.length;
          double stdDev = sqrt(variance);

          setState(() {
            _averageWindSpeed = mean;
            _windSpeedHistory = windSpeeds.map<double>((speed) => speed.toDouble()).toList();
            _historicalMean = mean;
            _historicalStdDev = stdDev;
          });
        } else {
          throw Exception('Invalid wind speed data format');
        }
      } else {
        throw Exception('Failed to load wind speed data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching historical wind speed data: $e');
    }

    try {
      final response = await http.get(Uri.parse(apiUrl2));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData != null && jsonData['current'] != null && jsonData['current']['wind_speed_10m'] != null) {
          final dynamic currentSpeed = jsonData['current']['wind_speed_10m'];
          setState(() {
            _currentWindSpeed = currentSpeed.toDouble();
          });
        } else {
          throw Exception('Invalid current wind speed data format');
        }
      } else {
        throw Exception('Failed to load current wind speed data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching current wind speed data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  final Random _random = Random();

  double _generateRandomNormal() {
    double u1 = 1.0 - _random.nextDouble(); // Convert [0, 1) to (0, 1]
    double u2 = 1.0 - _random.nextDouble();
    double standardNormal = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2); // Standard normal distribution
    return standardNormal;
  }

  // Simulate wind speed based on historical data using standard deviation
  double simulateWindSpeed(double currentSpeed, double stdDev) {
    double randomValue = _generateRandomNormal();
    return currentSpeed + randomValue * stdDev;
  }

  // Run multiple simulations
  List<double> runSimulations(double currentSpeed, int simulationsCount, double stdDev) {
    List<double> results = [];
    for (int i = 0; i < simulationsCount; i++) {
      results.add(simulateWindSpeed(currentSpeed, stdDev));
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_latitude, _longitude);
    _calculateNextSevenDays();
  }

  // Calculate the next 7 days starting from today
  void _calculateNextSevenDays() {
    DateTime now = DateTime.now();
    print (now);
    for (int i = 2; i < 9; i++) {
      DateTime nextDay = now.add(Duration(days: i));
      _nextSevenDays.add(DateFormat('EEEE, MMM d').format(nextDay));  // Format the date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wind Speed Forecast'),
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                'Current Wind Speed: ${_averageWindSpeed.toStringAsFixed(1)} km/hr',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(Icons.date_range),
                 Text(
                'Tuesday, 25/06/2024',
                style: TextStyle(fontSize: 16),
              ),
              ],),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Text(
                          'Wind Speed Prediction for Next 7 Days ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        // Check if _sevenDaysWindSpeed is not empty before building DataTable and LineChart
                        if (_sevenDaysWindSpeed.isNotEmpty) ...[
                          DataTable(
                            columnSpacing: 16.0,
                            border: TableBorder.all(width: 1, color: Colors.grey),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Day',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Wind Speed (km/hr)',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: List.generate(
                              _sevenDaysWindSpeed.length,
                              (index) => DataRow(
                                cells: [
                                  DataCell(
                                    Center(
                                      child: Text(
                                        _nextSevenDays[index],  // Use the calculated date
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        '${_sevenDaysWindSpeed[index].toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 300,
                            padding: EdgeInsets.all(16),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toStringAsFixed(1),
                                          style: TextStyle(
                                              color: Colors.black, fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'Day ${value.toInt() + 1}',
                                            style: TextStyle(
                                                color: Colors.black, fontSize: 12),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                      _sevenDaysWindSpeed.length,
                                      (index) => FlSpot(index.toDouble(), _sevenDaysWindSpeed[index]),
                                    ),
                                    isCurved: true,
                                    barWidth: 4,
                                    belowBarData: BarAreaData(show: true),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            List<double> simulatedSpeeds = [];
                            _sevenDaysWindSpeed = [];
                            for (int i = 0; i < 7; i++) {
                              double sum = 0.0;
                              simulatedSpeeds = runSimulations(_currentWindSpeed, 1000, _historicalStdDev);
                              for (int j = 0; j < simulatedSpeeds.length; j++) {
                                sum += simulatedSpeeds[j];
                              }
                              _currentWindSpeed = (sum / simulatedSpeeds.length);
                              _sevenDaysWindSpeed.add(sum / simulatedSpeeds.length);
                            }
        
                            setState(() {
                              _windSpeedHistory = _sevenDaysWindSpeed;
                            });
                          },
                          child: Text('Run Monte Carlo Simulation'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarloWindDirection()
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_forward, color: Colors.white),
                          label: Text('Wind Direction',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WindSpeedForecasting(),
  ));
}
