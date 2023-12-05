import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'env.dart';

class SearcByCityComponent extends StatefulWidget {
  const SearcByCityComponent({super.key, required this.onComplete});
  final ValueChanged<List<Map<String, dynamic>>> onComplete;

  @override
  State<SearcByCityComponent> createState() => _SearcByCityComponentState();
}

class _SearcByCityComponentState extends State<SearcByCityComponent> {
  bool _isProcessing = false;
  Map<String, dynamic> _response = {};
  List<dynamic> _searchResponse = [];
  List<Map<String, dynamic>> _responseList = [{}];
  String _error = "";
  final _cityNameTextController = TextEditingController();
  final _cityNameFocusNode = FocusNode();

  Future<void> getCity(city) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=100&appid=${weather_key}'));
      setState(() {
        _searchResponse = json.decode(response.body);
        _responseList = _searchResponse.cast<Map<String, dynamic>>().toList();
        print(_responseList);
        widget.onComplete(_responseList);
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
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
                          _isProcessing = true;
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
