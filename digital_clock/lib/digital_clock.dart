// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

enum _Element {
  background,
  text,
  shadow,
}

final numCats = 7;

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  Timer _modelTimer;
  var _temperature = '';
  var _temperatureRange = '';
  WeatherCondition _condition;
  var _location = '';
  String _prevImage = ''; // for fade-in
  String _catImage = 'assets/images/cat0.jpg';

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _modelTimer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }
  
  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '${widget.model.low} - ${widget.model.highString}';
      _condition = widget.model.weatherCondition;
      _location = widget.model.location;
      _prevImage = _catImage;
      // In case random give the same image
      while(_catImage == _prevImage) {
        _catImage = getRandomCatImage();
      }

      _modelTimer = Timer(Duration(seconds: 30), _updateModel);
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  Widget filledImage(String imagePath, BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(imagePath),
        ),
      ),
    );
  }

  Widget shadowedIcon(IconData icon){
    return Stack(
      children: <Widget>[
        Positioned(
          left: 1.0,
          top: 2.0,
          child: BoxedIcon(icon, color: Colors.black54),
        ),
        BoxedIcon(icon, color: Colors.white),
      ],
    );
  }

  IconData getWeatherIcon(WeatherCondition condition){
    switch(condition){
      case WeatherCondition.cloudy:
        return WeatherIcons.cloudy;
      case WeatherCondition.foggy:
        return WeatherIcons.fog;
      case WeatherCondition.rainy:
        return WeatherIcons.rain;
      case WeatherCondition.snowy:
        return WeatherIcons.snow;
      case WeatherCondition.sunny:
        return WeatherIcons.day_sunny;
      case WeatherCondition.thunderstorm:
        return WeatherIcons.thunderstorm;
      case WeatherCondition.windy:
        return WeatherIcons.windy;
      default:
        return WeatherIcons.day_sunny;
    }
  }

  String getRandomCatImage(){
    var rand = Random(DateTime.now().millisecondsSinceEpoch);
    int index = rand.nextInt(numCats);
    return "assets/images/cat" + index.toString() + ".jpg";
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 10;
    final wSep = 15.0;
    // final leftMargin = 40.0;
    // final hSep = 50.0;
    // final topMargin = 40.0;

    final rightMargin = 10.0;

    //final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Fantasy',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(4, 0),
        ),
      ],
    );

    final weatherStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Fantasy',
      fontSize: 15.0,
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(2, 0),
        ),
      ],
    );

    final weatherInfo = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shadowedIcon(getWeatherIcon(_condition)),
          Text(_temperature), 
          Text(_temperatureRange),
          Text(_location),
        ],
      ),
    );    


    return Container(
      color: colors[_Element.background],
      child: DefaultTextStyle(
        style: defaultStyle,
        child: Stack(
          children: <Widget>[
            filledImage(_catImage, context),
            Positioned(right: rightMargin + 2* (fontSize + wSep), top: 0, child: Text(hour)),
            Positioned(right: rightMargin + 2* fontSize + wSep + wSep/4, top: 0, child: Text(":")),
            Positioned(right: rightMargin + fontSize + wSep, top: 0, child: Text(minute)),
            Positioned(right: rightMargin + fontSize + wSep/4, top: 0, child: Text(":")),
            Positioned(right: rightMargin, top: 0, child: Text(second)),
            Positioned(left: 0, bottom: 0,
              child: DefaultTextStyle(
                style: weatherStyle,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: weatherInfo,
                ),
              )
            ),
          ],
        ),
      )
    );
  }
}
