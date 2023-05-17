import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_barometer_plugin/flutter_barometer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BarometerValue _currentPressure = BarometerValue(0.0);
  double _buildingHeight = 0.0;

  @override
  void initState() {
    super.initState();
    FlutterBarometer.currentPressureEvent.listen((event) {
      setState(() {
        _currentPressure = event;
      });
    });
  }

  void estimateHeight() {
    if (_currentPressure.hectpascal == 0.0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Barometer not available.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    double basePressure = _currentPressure.hectpascal;
    double summitPressure =
        basePressure * exp(-_buildingHeight / (8.31 * 288.15 / 0.0289644));
    double height =
        log(basePressure / summitPressure) * (8.31 * 288.15 / 0.0289644);

    setState(() {
      _buildingHeight = height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Barometer App'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(_currentPressure.hectpascal * 1000).round() / 1000} hPa',
              style: TextStyle(
                fontSize: 70,
              ),
            ),
            TextButton(
              onPressed: estimateHeight,
              child: Text('Estimate Building Height'),
            ),
            if (_buildingHeight != 0.0) ...[
              SizedBox(height: 20),
              Text(
                'Estimated Building Height:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_buildingHeight.toStringAsFixed(2)} meters',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
