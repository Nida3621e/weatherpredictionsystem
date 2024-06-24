import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DewPointForecast extends StatefulWidget {
  @override
  _DewPointForecastState createState() => _DewPointForecastState();
}

class _DewPointForecastState extends State<DewPointForecast> {
  String _city = 'Karachi';
  double _averageDewPoint = 0.0;
  List<double> _dewPointHistory = [];
  List<double> _sevenDaysDewPoint = [];
  double _latitude = 24.8608;
  double _longitude = 67.0104;
  dynamic _currentDewPoint = 0.0;
  double _historicalMean = 0.0;
  double _historicalStdDev = 0.0;
  List<double> results = [];
  List<double> averageDewPointPoints = [];
  List<String> forecastDates = [];

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=dew_point_2m&timezone=GMT';
    final apiUrl2 =
        'https://api.open-meteo.com/v1/forecast?latitude=$_latitude&longitude=$_longitude&current=dew_point_2m';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dewPoints = jsonData['hourly']['dew_point_2m'];
        double sum = 0.0;

        dewPoints.forEach((dewPoint) {
          sum += dewPoint.toDouble(); // Ensure conversion to double
        });

        double mean = sum / dewPoints.length;
        double variance = dewPoints
                .map((temp) => pow(temp.toDouble() - mean, 2))
                .reduce((a, b) => a + b) /
            dewPoints.length;
        double stdDev = sqrt(variance);

        setState(() {
          _averageDewPoint = mean;
          _dewPointHistory =
              dewPoints.map<double>((temp) => temp.toDouble()).toList();
          _historicalMean = mean;
          _historicalStdDev = stdDev;
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
        final dynamic current = jsonData1['current']['dew_point_2m'];

        setState(() {
          _currentDewPoint = current.toDouble(); // Ensure conversion to double
        });

        // Run simulations after fetching the current dew point
        runSimulations(_currentDewPoint, 1000, _historicalStdDev);
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

  // Simulate dew point based on historical data using standard deviation
  double simulateDewPoint(double currentDewPoint, double stdDev) {
    double randomValue = _generateRandomNormal();
    return currentDewPoint + randomValue * stdDev;
  }

  double calculateAverage(List<double> data) {
    return data.reduce((a, b) => a + b) / data.length;
  }

  // Run multiple simulations
  void runSimulations(
      double currentDewPoint, int simulationsCount, double stdDev) {
    averageDewPointPoints.clear(); // Clear previous simulation results
    forecastDates.clear(); // Clear previous dates
    // Run Simulations for next 7 days
    for (int day = 0; day < 7; day++) {
      results.clear();
      for (int i = 0; i < simulationsCount; i++) {
        results.add(simulateDewPoint(currentDewPoint, stdDev));
      }
      averageDewPointPoints.add(calculateAverage(results));

      // Add the forecast date
      DateTime forecastDate = DateTime.now().add(Duration(days: day));
      String formattedDate = DateFormat('EEEE, MMMM d').format(forecastDate);
      forecastDates.add(formattedDate);
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
        
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Text('Dew Point Forecast',
                  style: TextStyle(color: Colors.white, fontSize: 27)),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                 gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color(0xFF330867),
        Color(0xFF30cfd0),
      ],
    ),
  ),
            ),
          ),
        ),
        body: averageDewPointPoints.isNotEmpty
            ? SingleChildScrollView(
                child: Container(
                   
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
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
                            '${_averageDewPoint.toStringAsFixed(2)}°C',
                            style: TextStyle(
                                fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Icon(Icons.thermostat),
                              Text('Average Dew Point'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                                    spots: averageDewPointPoints
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
                          )),
                      SizedBox(height: 20),
                      Text("Dew Point Forecast for Next 7 Days",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      if (averageDewPointPoints.isNotEmpty)
                        Column(
                          children: [
                            for (int i = 0;
                                i < averageDewPointPoints.length;
                                i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Container(
                                   decoration: BoxDecoration(
                                    borderRadius:BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
               stops: [
      0.2,
      0.5,
      0.8,
      0.7
    ],
    
  colors: [
      Colors.blue[50]!,
      Color.fromARGB(255, 193, 224, 250)!,
      const Color.fromARGB(255, 153, 205, 248)!,
      Colors.blue[300]!
    ],)),
                                  child: Row(
                                    children: [
                                      Container(
                                        
                                          width: 80,
                                          height: 70,
                                          child: Image(
                                              image: AssetImage(
                                                  "assets/images/dew.png"))),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(forecastDates[i], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                                          Text(
                                              '${averageDewPointPoints[i].toStringAsFixed(2)}°C', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                                              
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
