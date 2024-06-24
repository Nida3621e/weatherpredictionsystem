import 'package:flutter/material.dart';
import 'api_service.dart';
import 'monte_carlo_simulation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'build_graph.dart';

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  ApiService apiService = ApiService();
  List<double>? predictions;
  String cityName = "Berlin";
  double? averagePressure;
  bool isLoading = false;

  Future<void> fetchAndSimulate() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<double> surfacePressures = await apiService.fetchSurfacePressure();
      MonteCarloSimulation simulation = MonteCarloSimulation(pressures: surfacePressures);
      List<double> simulationResults = simulation.runSimulation();
      setState(() {
        predictions = simulationResults;
        averagePressure = simulationResults.reduce((a, b) => a + b) / simulationResults.length;
      });
    } catch (e) {
      print("Error fetching or simulating data: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchGraph() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<double> surfacePressures = await apiService.fetchSurfacePressure();
      MonteCarloSimulation simulation = MonteCarloSimulation(pressures: surfacePressures);
      List<double> simulationResults = simulation.runSimulation();
      setState(() {
        predictions = simulationResults;
        averagePressure = simulationResults.reduce((a, b) => a + b) / simulationResults.length;
      });
    } catch (e) {
      print("Error fetching or simulating data: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  void navigateToGraphPage() {
    if (predictions != null && averagePressure != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuildGraphPage(
            predictions: predictions!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Prediction'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'City: $cityName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Average Surface Pressure: ${averagePressure?.toStringAsFixed(2)} hPa', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Expanded(child: ListView.builder(
                itemCount: predictions!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Day ${index + 1}: ${predictions![index].toStringAsFixed(2)} hPa'),
                  );
                },
              )),
              ElevatedButton(
                    onPressed: navigateToGraphPage,
                    child: Text('Generate graph'),
                  )
            ],
          ),
        ),
      )

    );
  }
}
