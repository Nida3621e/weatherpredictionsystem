import 'dart:math';

class MonteCarloSimulation {
  final List<double> pressures;
  final int days;
  final int simulations;

  MonteCarloSimulation({required this.pressures, this.days = 7, this.simulations = 1000});

  List<double> runSimulation() {
    final random = Random();
    final List<double> averagePredictions = List.filled(days, 0.0);

    for (int i = 0; i < simulations; i++) {
      double pressure = pressures.last;
      for (int j = 0; j < days; j++) {
        double change = random.nextGaussian();
        pressure += change;
        averagePredictions[j] += pressure;
      }
    }

    return averagePredictions.map((sum) => sum / simulations).toList();
  }
}

extension RandomExtensions on Random {
  double nextGaussian() {
    double u1 = nextDouble();
    double u2 = nextDouble();
    double z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return z0;
  }
}

