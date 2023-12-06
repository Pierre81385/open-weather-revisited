import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';

class SearcByCityComponent extends StatefulWidget {
  const SearcByCityComponent(
      {super.key,
      required this.onStart,
      required this.onWeatherComplete,
      required this.onSearchComplete});
  final ValueChanged<bool> onStart;
  final ValueChanged<List<Map<String, dynamic>>> onWeatherComplete;
  final ValueChanged<List<Map<String, dynamic>>> onSearchComplete;

  @override
  State<SearcByCityComponent> createState() => _SearcByCityComponentState();
}

class _SearcByCityComponentState extends State<SearcByCityComponent> {
  bool _isProcessing = false;
  List<Map<String, dynamic>> _response = [];
  final _cityNameTextController = TextEditingController();
  final _cityNameFocusNode = FocusNode();

  Future<void> getCity(city) async {
    print('getting city search results');
    try {
      await http
          .get(Uri.parse(
              'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=100&appid=${weather_key}'))
          .then((response) {
        final List<dynamic> decodedResponse = json.decode(response.body);
        print('city search decoded: ${decodedResponse.toString()}');
        final List<Map<String, dynamic>> decodedList =
            decodedResponse.cast<Map<String, dynamic>>().toList();
        setState(() {
          widget.onSearchComplete(decodedList);
        });
        getWeather(decodedList);
      });
    } catch (e) {
      setState(() {
        print(e.toString());
        _isProcessing = false;
      });
    }
  }

  Future<void> getWeather(cityData) async {
    try {
      for (var i = 0; i < cityData.length; i++) {
        print(
            'getting weather at ${cityData[i]['lon']} by ${cityData[i]['lon']}');

        final response = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/3.0/onecall?lat=${cityData[i]['lat']}&lon=${cityData[i]['lon']}&exclude=minutely,hourly,daily,alerts&appid=${weather_key}&units=imperial'));
        final decoded = json.decode(response.body);
        print('decoded weather response: ${decoded}');
        _response.add(decoded);
      }
      setState(() {
        widget.onWeatherComplete(_response);
        widget.onStart(false);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityNameTextController,
                    focusNode: _cityNameFocusNode,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: "City Name",
                      labelStyle: TextStyle(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.onStart(true);
                          getCity(_cityNameTextController.text);
                        });
                      },
                      icon: const Icon(Icons.search)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
