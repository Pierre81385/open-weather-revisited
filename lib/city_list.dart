import 'dart:convert';
import 'package:open_weather_revisited/current_weather.dart';

import 'env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'search.dart';

class CityListComponent extends StatefulWidget {
  const CityListComponent({super.key});

  @override
  State<CityListComponent> createState() => _CityListComponentState();
}

class _CityListComponentState extends State<CityListComponent> {
  late List<Map<String, dynamic>> _searchResult;
  late List<Map<String, dynamic>> _weatherResult;
  late List<Map<String, dynamic>> _tileDimensions;
  late bool _showSearch;

  @override
  void initState() {
    _searchResult = [];
    _weatherResult = [];
    _tileDimensions = [];
    _showSearch = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: SafeArea(
        top: _showSearch,
        bottom: _showSearch,
        child: SizedBox(
          height: height,
          width: width,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              AnimatedContainer(
                height: _showSearch ? 100 : 0.0,
                width: _showSearch ? width : 0,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
                // Define how long the animation should take.
                duration: const Duration(milliseconds: 250),
                // Provide an optional curve to make the animation feel smoother.
                curve: Curves.fastOutSlowIn,
                child: SearcByCityComponent(
                  onWeatherComplete: (value) {
                    print('got city weather: ${value.toString()}');
                    setState(() {
                      _weatherResult = value;
                    });
                  },
                  onSearchComplete: (value) {
                    print('search complete: ${value.toString()}');
                    setState(() {
                      _searchResult = value;
                    });
                  },
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _searchResult.length,
                itemBuilder: (BuildContext context, int index) {
                  double tileWidth = MediaQuery.of(context).size.width;
                  double tileHeight = 100;
                  _tileDimensions
                      .add({'width': tileWidth, 'height': tileHeight});
                  Map<String, dynamic> _current =
                      _weatherResult[index]['current'];
                  DateTime utcDateTimeCurrent =
                      DateTime.fromMillisecondsSinceEpoch(
                          (_current['dt'] +
                                  _weatherResult[index]['timezone_offset']) *
                              1000,
                          isUtc: true);
                  int _currentHour = utcDateTimeCurrent.hour;

                  return InkWell(
                    onTap: () {
                      for (var i = 0; i < _tileDimensions.length; i++) {
                        if (i == index) {
                          if (_tileDimensions[index]['height'] == tileHeight) {
                            setState(() {
                              _showSearch = false;
                              _tileDimensions[index]['height'] = height;
                              _tileDimensions[index]['width'] = width;
                            });
                          } else {
                            setState(() {
                              _showSearch = true;
                              _tileDimensions[index]['height'] = tileHeight;
                              _tileDimensions[index]['width'] = tileWidth;
                            });
                          }
                        } else {
                          if (_tileDimensions[i]['height'] == 0.0) {
                            setState(() {
                              _tileDimensions[i]['height'] = tileHeight;
                              _tileDimensions[i]['width'] = tileWidth;
                            });
                          } else {
                            setState(() {
                              _tileDimensions[i]['height'] = 0.0;
                              _tileDimensions[i]['width'] = 0.0;
                            });
                          }
                        }
                      }
                    },
                    child: AnimatedContainer(
                      height: _tileDimensions[index]['height'],
                      width: _tileDimensions[index]['width'],
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      // Define how long the animation should take.
                      duration: const Duration(seconds: 1),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.fastOutSlowIn,
                      child: ListView(
                        //padding: EdgeInsets.zero,
                        children: [
                          SizedBox(
                            height: _showSearch
                                ? _tileDimensions[index]['height']
                                : height * .9,
                            child: Card(
                              color: Colors.transparent,
                              elevation: 25,
                              child: _showSearch
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: _currentHour > 0 &&
                                                    _currentHour <= 4
                                                ? [
                                                    Colors.black,
                                                    Colors.blueGrey
                                                  ]
                                                : _currentHour > 4 &&
                                                        _currentHour <= 8
                                                    ? [
                                                        Colors.blueGrey,
                                                        Colors.green
                                                      ]
                                                    : _currentHour > 8 &&
                                                            _currentHour <= 12
                                                        ? [
                                                            Colors.green,
                                                            Colors.yellow
                                                          ]
                                                        : _currentHour > 12 &&
                                                                _currentHour <=
                                                                    16
                                                            ? [
                                                                Colors.yellow,
                                                                Colors.pink
                                                              ]
                                                            : _currentHour >
                                                                        16 &&
                                                                    _currentHour <=
                                                                        20
                                                                ? [
                                                                    Colors.pink,
                                                                    Colors.blue
                                                                  ]
                                                                : [
                                                                    Colors.blue,
                                                                    Colors.black
                                                                  ]),
                                      ),
                                      child: ListTile(
                                        tileColor: Colors.transparent,
                                        title: Text(
                                          _searchResult[index]['name'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text(
                                              '${_searchResult[index]['state']}, ${_searchResult[index]['country']}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : CurrentWeatherComponent(
                                      data: _weatherResult[index],
                                      width: width,
                                      height: height,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
