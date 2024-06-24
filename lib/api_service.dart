import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = "https://api.open-meteo.com/v1/forecast?latitude=24.8608&longitude=67.0104&hourly=surface_pressure";

  Future<List<double>> fetchSurfacePressure() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<double> surfacePressure = [];
      for (var pressure in data['hourly']['surface_pressure']) {
        surfacePressure.add(pressure.toDouble());
      }
      return surfacePressure;
    } else {
      throw Exception('Failed to load surface pressure data');
    }
  }
}
