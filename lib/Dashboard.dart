import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weatherpredictionsystems/containerWidget.dart';
import 'package:weatherpredictionsystems/gaussianDistributed.dart';
import 'package:weatherpredictionsystems/normalDistributed.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double _latitude = 24.8608;
  double _longitude = 67.0104;
  double _currentTemperature=0.0;

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    final apiUrl=
        'https://api.open-meteo.com/v1/forecast?latitude=$_latitude&longitude=$_longitude&current=temperature_2m';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData1 = json.decode(response.body);
        final dynamic current = jsonData1['current']['temperature_2m'];

        setState(() {
          _currentTemperature = current;
        });
      } else {
        throw Exception('Failed to load weather data 2');
      }
    } catch (e) {
      print('Error fetching weather data 2: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_latitude, _longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("KARACHI",style: TextStyle(fontSize:20),),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_currentTemperature}",style: TextStyle(
                              fontSize: 80
                          ),),
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Icon(Icons.circle_outlined),
                          )
                        ],
                      )
                    ],
                  ),
                  Divider(),
                  Text("VIEW PREDICTIONS",textAlign: TextAlign.center,),
                  Divider(),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Containerwidget(
                        image: "assets/images/temp.png",
                        name:"Temperature",
                        materialApp: GaussianDistributed(),
                      ),Containerwidget(
                        image: "assets/images/temp.png",
                        name:"Wind Speed/Direction",
                        materialApp: NormalDistributed(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Containerwidget(
                        image: "assets/images/temp.png",
                        name:"Dew point",
                        materialApp: GaussianDistributed(),
                      ),Containerwidget(
                        image: "assets/images/temp.png",
                        name:"Humidity",
                        materialApp: NormalDistributed(),
                      ),
                    ],
                  ),SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Containerwidget(
                        image: "assets/images/temp.png",
                        name:"Cloud",
                        materialApp: GaussianDistributed(),
                      ),Containerwidget(
                        image: "assets/images/temp.png",
                        name:"Pressure",
                        materialApp: NormalDistributed(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

    );
  }
}
