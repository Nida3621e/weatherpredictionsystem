// monte_carlo.dart

import 'dart:math';

List<double> monteCarloSimulation(List<double> historicalData, int simulations) {
  final random = Random();
  List<double> futurePredictions = [];

  for (int i = 0; i < simulations; i++) {
    double prediction = historicalData[random.nextInt(historicalData.length)];
    futurePredictions.add(prediction);
  }

  return futurePredictions;
}

double calculateAverage(List<double> data) {
  return data.reduce((a, b) => a + b) / data.length;
}