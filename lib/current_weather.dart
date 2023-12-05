import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'env.dart';

class CurrentWeatherComponent extends StatefulWidget {
  const CurrentWeatherComponent(
      {super.key,
      required this.data,
      required this.width,
      required this.height});
  final Map<String, dynamic> data;
  final double width;
  final double height;

  @override
  State<CurrentWeatherComponent> createState() =>
      _CurrentWeatherComponentState();
}

class _CurrentWeatherComponentState extends State<CurrentWeatherComponent> {
  late Map<String, dynamic> _data = {};
  late Map<String, dynamic> _response = {};
  late Map<String, dynamic> _current = {};

  late double _lon = 0.0;
  late double _lat = 0.0;
  late double _width = 0.0;
  late double _height = 0.0;
  bool _isProcessing = true;

  Future<void> getWeather(lon, lat) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&exclude=minutely,hourly,daily,alerts&appid=${one_call}&units=imperial'));
      setState(() {
        _response = json.decode(response.body);
        _current = _response['current'];
        _isProcessing = false;
      });
    } catch (e) {
      List<Map<String, dynamic>> err = [{}];
      setState(() {
        err.add(e as Map<String, dynamic>);
        _isProcessing = false;
      });
    }
  }

  @override
  void initState() {
    _data = widget.data;
    _lon = _data['lon'];
    _lat = _data['lat'];
    _width = widget.width;
    _height = widget.height;
    getWeather(_lon, _lat);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 15,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.yellow, Colors.pink],
          ),
        ),
        child: _isProcessing
            ? SizedBox()
            : SizedBox(
                width: _width,
                height: _height,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _data['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${_current['temp'].toString()}°F',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'feels like,',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_current['feels_like'].toString()}°F',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          _current['sunrise'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Sunrise',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _current['sunset'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Sunset',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Pressure ${_current['pressure'].toString()} hPa',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Humidity ${_current['humidity'].toString()}%',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Dew point ${_current['dew_point'].toString()}°F',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'UV Indext ${_current['uvi'].toString()}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Cloud Cover ${_current['clouds'].toString()}%',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Visibility ${_current['visibility'].toString()}m',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Wind speed ${_current['wind_speed'].toString()}/mph',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Gusts to ${_current['wind_gust'].toString()}/mph',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Wind direction ${_current['wind_deg'].toString()}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
