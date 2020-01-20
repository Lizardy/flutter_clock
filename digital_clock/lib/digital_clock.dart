// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  backgroundStartGradient,
  backgroundEndGradient,
  text,
  shadow,
}

final _lightTheme = {
  _Element.backgroundStartGradient: Colors.grey[50],
  _Element.backgroundEndGradient: Colors.grey[300],
  _Element.text: Colors.teal[700],
  _Element.shadow: Colors.tealAccent,
};

final _darkTheme = {
  _Element.backgroundStartGradient: Colors.indigo[900],
  _Element.backgroundEndGradient: Colors.indigo[700],
  _Element.text: Colors.tealAccent[100],
  _Element.shadow: Colors.tealAccent[700],
};

// bitmaps for each digit: 3 "pixels" horizontally X 5 "pixels" vertically
// '0'-'9': digits, 1-5 keys: row numbers, 0-5 values: pixel size multiplier
const Map<String, Map<int, List<int>>> digitsBlueprints = {
  '0': {
    1: [1, 1, 1],
    2: [2, 0, 2],
    3: [3, 0, 3],
    4: [4, 0, 4],
    5: [5, 5, 5]
  },
  '1': {
    1: [0, 1, 0],
    2: [2, 2, 0],
    3: [0, 3, 0],
    4: [0, 4, 0],
    5: [0, 5, 0]
  },
  '2': {
    1: [1, 1, 1],
    2: [0, 0, 2],
    3: [3, 3, 3],
    4: [4, 0, 0],
    5: [5, 5, 5]
  },
  '3': {
    1: [1, 1, 1],
    2: [0, 0, 2],
    3: [3, 3, 3],
    4: [0, 0, 4],
    5: [5, 5, 5]
  },
  '4': {
    1: [1, 0, 1],
    2: [2, 0, 2],
    3: [3, 3, 3],
    4: [0, 0, 4],
    5: [0, 0, 5]
  },
  '5': {
    1: [1, 1, 1],
    2: [2, 0, 0],
    3: [3, 3, 3],
    4: [0, 0, 4],
    5: [5, 5, 5]
  },
  '6': {
    1: [1, 1, 1],
    2: [2, 0, 0],
    3: [3, 3, 3],
    4: [4, 0, 4],
    5: [5, 5, 5]
  },
  '7': {
    1: [1, 1, 1],
    2: [0, 0, 2],
    3: [0, 3, 0],
    4: [0, 4, 0],
    5: [0, 5, 0]
  },
  '8': {
    1: [1, 1, 1],
    2: [2, 0, 2],
    3: [3, 3, 3],
    4: [4, 0, 4],
    5: [5, 5, 5]
  },
  '9': {
    1: [1, 1, 1],
    2: [2, 0, 2],
    3: [3, 3, 3],
    4: [0, 0, 4],
    5: [5, 5, 5]
  },
};

const List<List<List<int>>> dividerBlueprints = [
  [
    [0, 0, 0],
    [0, 1, 0],
    [0, 0, 0],
    [0, 4, 0],
    [0, 0, 0]
  ],
  [
    [0, 0, 0],
    [0, 3, 0],
    [0, 0, 0],
    [0, 2, 0],
    [0, 0, 0]
  ],
];

class DigitPixel extends StatelessWidget {
  final num pixelSizeMax;
  final num pixelSizeLit;
  final bool backLit;
  final bool lit;

  DigitPixel(this.pixelSizeMax, this.pixelSizeLit, this.backLit, this.lit);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Container(
        width: pixelSizeMax,
        height: pixelSizeMax,
        color: backLit
            ? colors[_Element.shadow]
            : colors[_Element.shadow].withOpacity(0.0),
        alignment: Alignment(0, 0),
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.ease,
          width: lit ? pixelSizeLit : 0,
          height: lit ? pixelSizeLit : 0,
          color: colors[_Element.text],
        ),
      ),
    );
  }
}

class DigitVisualization extends StatefulWidget {
  final String digit;
  final int second;

  DigitVisualization(this.digit, this.second);

  @override
  _DigitVisualizationState createState() => _DigitVisualizationState();
}

class _DigitVisualizationState extends State<DigitVisualization> {
  Map<int, Map<int, List<int>>> digitAnimationBlueprints = {};
  Map<int, List<int>> digitBlueprints;
  final emptyRow = [0, 0, 0];
  String oldDigit;
  int step;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    oldDigit = widget.digit;
    digitAnimationBlueprints = {};
    digitBlueprints = digitsBlueprints.containsKey(widget.digit)
        ? digitsBlueprints[widget.digit]
        : throw Exception('digit\'s blueprint not found for ${widget.digit}');
    // animation in 6 steps x 10 times during 1 minute
    for (int step = 0; step < 6; step++) {
      Map<int, List<int>> rows = {};
      int rowNumber;
      // 5-step empty/placeholder rows
      for (rowNumber = 1; rowNumber <= 5 - step; rowNumber++) {
        rows[rowNumber] = emptyRow;
      }
      // the rest of the rows with a visible part of the "growing up" digit
      for (int rowNumberVisibleDigit = step, rowNumber = 5;
          rowNumberVisibleDigit > 0;
          rowNumberVisibleDigit--, rowNumber--) {
        rows[rowNumber] = digitBlueprints[rowNumber]
            .map((e) => (e > 0) ? rowNumberVisibleDigit : 0)
            .toList();
      }
      digitAnimationBlueprints[step] = rows;
    }
  }

  @override
  Widget build(BuildContext context) {
    final num padding = (MediaQuery.of(context).size.width / 15 -
            MediaQuery.of(context).size.width / 20) /
        5;

    if (oldDigit != widget.digit) init();
    List<List<Widget>> _rows = [];
    int step = widget.second - 6 * (widget.second / 6).floor();
    num pixelSizeMax = MediaQuery.of(context).size.width / 20;
    for (int j = 1; j <= 5; j++) {
      List<Widget> _row = [];
      for (var k = 0; k < 3; k++) {
        int pixelSizeMultiplier = digitAnimationBlueprints[step][j][k];
        num pixelSizeLit = pixelSizeMax / 5 * (pixelSizeMultiplier + 0.5);
        bool pixelBackLit = digitBlueprints[j][k] > 0 ? true : false;
        bool pixelLit =
            digitBlueprints[j][k] > 0 && pixelSizeMultiplier > 0 ? true : false;
        _row.add(
            DigitPixel(pixelSizeMax, pixelSizeLit, pixelBackLit, pixelLit));
      }
      _rows.add(_row);
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: _rows
            .map((List<Widget> _row) => Row(
                  children: _row,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ))
            .toList(),
      ),
    );
  }
}

class DividerPixel extends StatelessWidget {
  final int litMultiplier;

  DividerPixel(this.litMultiplier);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final bool lit = litMultiplier > 0 ? true : false;
    final pixelSizeMax = MediaQuery.of(context).size.width / 20;
    final pixelSizeLit = pixelSizeMax / 5 * (litMultiplier + 0.5);
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Container(
        width: pixelSizeMax,
        height: pixelSizeMax,
        color: lit
            ? colors[_Element.shadow]
            : colors[_Element.backgroundEndGradient].withOpacity(0.0),
        alignment: Alignment(0, 0),
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.ease,
          width: pixelSizeLit,
          height: pixelSizeLit,
          color: lit
              ? colors[_Element.text]
              : colors[_Element.backgroundEndGradient].withOpacity(0.0),
        ),
      ),
    );
  }
}

class DividerVisualization extends StatelessWidget {
  final isSecondEven;

  DividerVisualization(this.isSecondEven);

  @override
  Widget build(BuildContext context) {
    final num padding = (MediaQuery.of(context).size.width / 15 -
            MediaQuery.of(context).size.width / 20) /
        5;
    List<List<int>> _blueprint =
        isSecondEven ? dividerBlueprints.first : dividerBlueprints.last;
    List<List<Widget>> _rows = [];
    _blueprint.forEach((List<int> blueprintRow) {
      List<Widget> _row = [];
      blueprintRow.forEach((int pixelValue) {
        _row.add(DividerPixel(pixelValue));
      });
      _rows.add(_row);
    });
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: _rows
            .map((List<Widget> _row) => Row(
                  children: _row,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ))
            .toList(),
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
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = _dateTime.second;
    final isSecondEven = _dateTime.second % 2 == 0 ? true : false;

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors[_Element.backgroundStartGradient],
            colors[_Element.backgroundEndGradient]
          ],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DigitVisualization(hour[0], second),
                DigitVisualization(hour[1], second),
                DividerVisualization(isSecondEven),
                DigitVisualization(minute[0], second),
                DigitVisualization(minute[1], second),
              ],
            ),
          ],
        ));
  }
}
