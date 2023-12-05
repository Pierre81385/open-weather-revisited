import 'dart:convert';
import 'package:intl/intl.dart';
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
  late Map<String, dynamic> _weather = {};
  late double _lon = 0.0;
  late double _lat = 0.0;
  late double _width = 0.0;
  late double _height = 0.0;
  late DateTime _sunrise = DateTime.now();
  late DateTime _sunset = DateTime.now();
  late int _currentHour = 12;
  late int _currentMinute = 12;
  bool _isPM = false;
  bool _isProcessing = true;
  int utcTimestamp = 1701689448;

  Future<void> getWeather(lon, lat) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&exclude=minutely,hourly,daily,alerts&appid=${one_call}&units=imperial'));
      setState(() {
        _response = json.decode(response.body);
        _current = _response['current'];
        _weather = _current['weather'][0] as Map<String, dynamic>;
        DateTime utcDateTimeCurrent = DateTime.fromMillisecondsSinceEpoch(
            (_current['dt'] + _response['timezone_offset']) * 1000,
            isUtc: true);
        _currentHour = utcDateTimeCurrent.hour;
        _currentMinute = utcDateTimeCurrent.minute;
        print(_currentHour.toString());
        DateTime utcDateTimeSunrise = DateTime.fromMillisecondsSinceEpoch(
            _current['sunrise'] * 1000,
            isUtc: true);
        _sunrise = utcDateTimeSunrise;
        DateTime utcDateTimeSunset = DateTime.fromMillisecondsSinceEpoch(
            _current['sunset'] * 1000,
            isUtc: true);
        _sunset = utcDateTimeSunset;
        _isProcessing = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
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
          image: DecorationImage(
              image: NetworkImage(
                  'https://openweathermap.org/img/wn/${_weather['icon']}@2x.png')),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: _currentHour > 0 && _currentHour <= 4
                  ? [Colors.black, Colors.blueGrey]
                  : _currentHour > 4 && _currentHour <= 8
                      ? [Colors.blueGrey, Colors.green]
                      : _currentHour > 8 && _currentHour <= 12
                          ? [Colors.green, Colors.yellow]
                          : _currentHour > 12 && _currentHour <= 16
                              ? [Colors.yellow, Colors.pink]
                              : _currentHour > 16 && _currentHour <= 20
                                  ? [Colors.pink, Colors.blue]
                                  : [Colors.blue, Colors.black]),
        ),
        child: _isProcessing
            ? const SizedBox()
            : SizedBox(
                width: _width,
                height: _height,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            _data['name'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.bold),
                          ),
                          // ignore: unnecessary_string_interpolations
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       '${_currentHour > 12 ? '${_currentHour - 12}:' : '${_currentHour}:'}${_currentMinute < 10 ? '0${_currentMinute}' : '${_currentMinute}'}',
                          //       style: const TextStyle(
                          //           color: Colors.white,
                          //           fontSize: 52,
                          //           fontWeight: FontWeight.bold),
                          //     ),
                          //     Text(
                          //       _currentHour > 12 ? 'PM' : 'AM',
                          //       style: const TextStyle(
                          //           color: Colors.white,
                          //           fontSize: 52,
                          //           fontWeight: FontWeight.bold),
                          //     )
                          //   ],
                          // ),
                        ],
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
                                const Text(
                                  'feels like,',
                                  style: TextStyle(
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_sunrise.hour > 12 ? '${_sunrise.hour - 12}:' : '${_sunrise.hour}:'}${_sunrise.minute < 10 ? '0${_sunrise.minute}' : '${_sunrise.minute}'} AM',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Text(
                                            'Sunrise',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_sunset.hour > 12 ? '${_sunset.hour - 12}:' : '${_sunset.hour}:'}${_sunset.minute < 10 ? '0${_sunset.minute}' : '${_sunset.minute}'} PM',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Text(
                                            'Sunset',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
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
