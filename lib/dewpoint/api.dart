import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchDewPointData(double latitude, double longitude) async {
  final response = await http.get(
    Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=dew_point_2m&timezone=GMT',
    ),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load dew point data');
  }
}