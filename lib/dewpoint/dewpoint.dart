import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api.dart';
import 'simulation.dart';

class WeatherForecastScreen extends StatefulWidget {
  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {

  late Future<Map<String, dynamic>> futureDewPointData;
  bool showSimulations = false;
  bool isLoading = false;
  bool showGraph = false;
  List<double> averageDewPoints = [];

  @override
  void initState() {
    super.initState();
    futureDewPointData = fetchDewPointData(24.8608, 67.0104); // Fetch dew point data
  }

  void runSimulations() async {
    setState(() {
      isLoading = true;
    });

    try {

      final dewPointData = await futureDewPointData;

     

      List<double> dewPoints = (dewPointData['hourly']['dew_point_2m'] as List<dynamic>)
          .map<double>((dynamic value) => value.toDouble())
          .toList();

      // Clear previous simulations
     
      averageDewPoints.clear();

      // Run simulations for each of the next 7 days
      for (int day = 0; day < 7; day++) {
        
        List<double> simulatedDewPoints = monteCarloSimulation(dewPoints, 1000);
        averageDewPoints.add(calculateAverage(simulatedDewPoints));
      }

      setState(() {
        showSimulations = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error running simulations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monte Carlo Weather Forecast'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: runSimulations,
                child: Text('Run Simulations'),
              ),
              if (showSimulations) ...[
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showGraph = false;
                    });
                  },
                  child: Text('Show Values'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showGraph = true;
                    });
                  },
                  child: Text('Show Graphs'),
                ),
                SizedBox(height: 20),
                if (showGraph)
                  Expanded(
                    child: ListView(
                      children: [
                      
                        Text(
                          'Dew Point Predictions for Next 7 Days',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
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
                                        style: TextStyle(color: Colors.black, fontSize: 10),
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
                                          style: TextStyle(color: Colors.black, fontSize: 10),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    7,
                                    (index) => FlSpot(index.toDouble(), averageDewPoints[index]),
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
                    ),
                  ),
                if (!showGraph)
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dew Point Predictions for Next 7 Days:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              for (int i = 0; i < averageDewPoints.length; i++)
                                Text('Day ${i + 1}: ${averageDewPoints[i].toStringAsFixed(2)}°'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if (isLoading) CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}