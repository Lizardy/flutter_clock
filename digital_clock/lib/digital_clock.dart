// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.grey[300],
  _Element.text: Colors.teal[700],
  _Element.shadow: Colors.tealAccent[100],
};

final _darkTheme = {
  _Element.background: Colors.indigo[900],
  _Element.text: Colors.tealAccent[100],
  _Element.shadow: Colors.teal,
};

// bitmaps for each digit: 3 "pixels" horizontally X 5 "pixels" vertically
const Map<String, List<List<bool>>> digitsBlueprints = {
  ':': [[false, false, false], [false, true, false], [false, false, false], [false, true, false], [false, false, false]],
  '0': [[true, true, true], [true, false, true], [true, false, true], [true, false, true], [true, true, true]],
  '1': [[false, true, false], [true, true, false], [false, true, false], [false, true, false], [false, true, false]],
  '2': [[true, true, true], [false, false, true], [true, true, true], [true, false, false], [true, true, true]],
  '3': [[true, true, true], [false, false, true], [true, true, true], [false, false, true], [true, true, true]],
  '4': [[true, false, true], [true, false, true], [true, true, true], [false, false, true], [false, false, true]],
  '5': [[true, true, true], [true, false, false], [true, true, true], [false, false, true], [true, true, true]],
  '6': [[true, true, true], [true, false, false], [true, true, true], [true, false, true], [true, true, true]],
  '7': [[true, true, true], [false, false, true], [false, true, false], [false, true, false], [false, true, false]],
  '8': [[true, true, true], [true, false, true], [true, true, true], [true, false, true], [true, true, true]],
  '9': [[true, true, true], [true, false, true], [true, true, true], [false, false, true], [true, true, true]],
};

class DigitPixel extends StatelessWidget {
  final bool lit;
  final int rowNumber;
  DigitPixel(this.lit, this.rowNumber);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final pixelSizeMax = MediaQuery.of(context).size.width / 20;
    final pixelSizeLit = pixelSizeMax / 5 * (rowNumber + 1.5);
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Container(
        width: pixelSizeMax,
        height: pixelSizeMax,
        color: lit ? colors[_Element.shadow] : colors[_Element.background],
        alignment: Alignment(0, 0),
        child: Container(
          width: pixelSizeLit,
          height: pixelSizeLit,
          color: lit ? colors[_Element.text] : colors[_Element.background],
        ),
      ),
    );
  }
}

class DigitVisualization extends StatelessWidget {
  final String digit;
  DigitVisualization(this.digit);

  @override
  Widget build(BuildContext context) {
    List<List<bool>> _blueprint = digitsBlueprints[digit];
    List<List<Widget>> _rows = [];
    int _index = 0;
    _blueprint.forEach((List<bool> blueprintRow){
      List<Widget> _row = [];
      blueprintRow.forEach((bool pixelValue) {
        _row.add(DigitPixel(pixelValue, _index));
      });
      _index++;
      _rows.add(_row);
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: _rows.map((List<Widget> _row) =>
            Row(
              children: _row,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            )
        ).toList(),
      ),
    );
  }
}

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

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
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh')
        .format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    return Container(
        color: colors[_Element.background],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DigitVisualization(hour[0]),
                DigitVisualization(hour[1]),
                DigitVisualization(':'),
                DigitVisualization(minute[0]),
                DigitVisualization(minute[1]),
              ],
            ),
          ],
        )
    );
  }
}
