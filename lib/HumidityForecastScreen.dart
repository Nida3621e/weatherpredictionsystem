import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sparkline/sparkline.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HumidityForecast extends StatefulWidget {
  @override
  _HumidityForecastState createState() => _HumidityForecastState();
}

class _HumidityForecastState extends State<HumidityForecast> {
  String _city = 'Karachi';
  double _averageHumidity = 0.0;
  List<double> _humidityHistory = [];
  List<double> _sevenDaysWeather = [];
  double _latitude = 24.8608;
  double _longitude = 67.0104;
  dynamic _currentHumidity = 0.0;
  double _historicalMean = 0.0;
  double _historicalStdDev = 0.0;
  List<double> results = [];
  List<double> averageHumidityPoints = [];

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=24.8608&longitude=67.0104&hourly=relative_humidity_2m&start_date=2024-05-01&end_date=2024-06-20';
    final apiUrl2 =
        'https://api.open-meteo.com/v1/forecast?latitude=$_latitude&longitude=$_longitude&current=relative_humidity_2m';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> humidities =
            jsonData['hourly']['relative_humidity_2m'];
        double sum = 0.0;

        humidities.forEach((humidity) {
          sum += humidity.toDouble(); // Ensure conversion to double
        });

        double mean = sum / humidities.length;
        double variance = humidities
                .map((temp) => pow(temp.toDouble() - mean, 2))
                .reduce((a, b) => a + b) /
            humidities.length;
        double stdDev = sqrt(variance);

        setState(() {
          _averageHumidity = mean;
          _humidityHistory =
              humidities.map<double>((temp) => temp.toDouble()).toList();
          _historicalMean = mean;
          _historicalStdDev = stdDev;
          print(_historicalMean);
          print(variance);
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
        final dynamic current = jsonData1['current']['relative_humidity_2m'];

        setState(() {
          _currentHumidity = current.toDouble(); // Ensure conversion to double
        });

        // Run simulations after fetching the current humidity
        runSimulations(_currentHumidity, 1000, _historicalStdDev);
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
  double simulateHumidity(double currentHumid, double stdDev) {
    double randomValue = _generateRandomNormal();
    return currentHumid + randomValue * stdDev;
  }

  double calculateAverage(List<double> data) {
    return data.reduce((a, b) => a + b) / data.length;
  }

  // Run multiple simulations
  void runSimulations(
      double currentHumid, int simulationsCount, double stdDev) {
    averageHumidityPoints.clear(); // Clear previous simulation results
    // Run Simulations for next 7 days
    for (int day = 0; day < 7; day++) {
      results.clear();
      for (int i = 0; i < simulationsCount; i++) {
        results.add(simulateHumidity(currentHumid, stdDev));
      }
      averageHumidityPoints.add(calculateAverage(results));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_latitude, _longitude);
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, MMMM d').format(now);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Humidity Forecast"),
        ),
        body: averageHumidityPoints.isNotEmpty
            ? SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Karachi',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        getCurrentDate(),
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_averageHumidity.toStringAsFixed(2)}%',
                            style: TextStyle(
                                fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Icon(Icons.water_drop_sharp),
                              Text('Average Humidity'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Humidity Forecast for Next 7 Days",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          if (averageHumidityPoints.isNotEmpty)
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (int i = 0;
                                        i < averageHumidityPoints.length;
                                        i++)
                                      Row(
                                        children: [
                                          Container(
                                              width: 50,
                                              height: 50,
                                              child: Image(
                                                  image: AssetImage(
                                                      "assets/images/humidLogo.png"))),
                                          Column(
                                            children: [
                                              Text("Day${i + 1}"),
                                              Text(
                                                  '${averageHumidityPoints[i].toStringAsFixed(2)}%'),
                                            ],
                                          )
                                        ],
                                      )
                                  ],
                                )),
                          SizedBox(
                            height: 40,
                          )
                        ],
                      ),
                      Container(
                          height: 300,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: LineChart(
                            LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: true),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.grey),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: averageHumidityPoints
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      return FlSpot(entry.key.toDouble() + 1,
                                          entry.value.toDouble());
                                    }).toList(),
                                    isCurved: true,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(show: false),
                                  )
                                ]),
                          ))
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
