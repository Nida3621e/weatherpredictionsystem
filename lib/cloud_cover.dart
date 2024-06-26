import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Cover',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PredictionForm(),
    );
  }
}

class PredictionForm extends StatefulWidget {
  @override
  _PredictionFormState createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {

  List<String> days = [];
  var current1=0;

  List<double> _dailyPredictions = [];
  bool _isLoading = false;
  String currentDate= '';
  String currentTime= '';
  //here
  String day1='';
  DateTime now=DateTime.now();



@override

  @override
  Widget build(BuildContext context) {
  day1 = DateFormat('EEEE').format(now);
  currentDate = DateTime.now().toString().substring(0,10);
  currentTime=DateTime.now().toString().substring(10,19);
  String day='';
  day=day1;
  for (int i = 0; i < 8; i++) {
  DateTime nextDay = now.add(Duration(days: i));
  String day2 = DateFormat('EEEE').format(nextDay);
  days.add(day2);
  }
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Cover',style: TextStyle(
          color: Colors.blue
        ),),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                _predictCloudCover();

              },
              child: Text('CLOUD COVER PREDICTION USING MONTE CARLO'),
            ),
            SizedBox(height: 20),
            Text('City: Karachi',style: TextStyle(
                fontSize: 20
            ),),
            Text('Day : $day',style: TextStyle(
                fontSize: 16
            ),),
            Text('Date : $currentDate',style: TextStyle(
                fontSize: 16
            ),),
            Text('Time :  $currentTime',style: TextStyle(
                fontSize: 16
            ),),

            Text('Cloud Cover : ${current1} %',style: TextStyle(
              fontSize: 16
            ),),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _dailyPredictions.isNotEmpty
                  ? LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _dailyPredictions.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],

                  maxX: _dailyPredictions.length.toDouble()-1,

                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text('Today');
                            case 1:
                              return Text(days[1].substring(0,3));
                            case 2:
                              return Text(days[2].substring(0,3));
                            case 3:
                              return Text(days[3].substring(0,3));
                            case 4:
                              return Text(days[4].substring(0,3));
                            case 5:
                              return Text(days[5].substring(0,3));
                            case 6:
                              return Text(days[6].substring(0,3));
                            case 7:
                              return Text(days[0].substring(0,3));
                            default:
                              return Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black),
                  ),
                  gridData: FlGridData(show: true),
                ),
              )
                  : Center(child: Text('No data to display')),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<double>> fetchData() async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=24.8608&longitude=67.0104&current=cloud_cover&hourly=cloud_cover&past_days=14&forecast_days=1';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hourlyData = data['hourly']['cloud_cover'] as List;
      final current=data['current']['cloud_cover'];
        current1=current;

      print(current);
      print(hourlyData);

      List<double> dailyData =
      hourlyData.take(336).map((e) => (e as num).toDouble()).toList();

      return dailyData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _predictCloudCover() async {
    setState(() {
      _isLoading = true;
      _dailyPredictions.clear();
    });

    try {
      var dailyData = await fetchData();
      print("first daily data"+'${dailyData}');

      for (int day = 0; day < 8; day++)
      {
        //daily results array or list
        List<double> dailyResults = [];
        Random random = Random();

        for (int i = 0; i < 1000; i++) {
          //jitni iterations utne randoms in a list.
          double sample = dailyData[random.nextInt(dailyData.length)];
          dailyResults.add(sample);
        }
        print("daily result "+'${dailyResults}');
//sare randoms ko mila kar overall prediction for a day
        double prediction = dailyResults.reduce((a, b) => a + b) / dailyResults.length;

        setState(() {
          // prediction overall of each day.
          _dailyPredictions.add(prediction);
        });
//assigning previous day random values for next day prediction
        dailyData = dailyResults;
        print("daily result after assignation"+'${dailyResults}');

      }
      _showPrediction(_dailyPredictions);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }
  void _showPrediction(List<double> dailyPredictions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Karachi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10),
              Text('Predicted Cloud Cover for next 7 Days:'),
              for (int i = 0; i < dailyPredictions.length; i++)
                Text(days[i]+': ${dailyPredictions[i].toStringAsFixed(2)}%'),
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

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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