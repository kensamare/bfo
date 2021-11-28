import 'dart:math';
import 'package:bfo/custom_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

import 'glScript.dart' show glScript;

late cFunction f;

double globalX = 0;
double globalY = 0;
double? min = null;

void main() {
  f = cFunction(function: 'x^2+y^2');
  f.calc(x: 2, y: 2);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BFO',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String value = graph();
    String options = generateOptions(value);
    dev.log(options);
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Echarts(
              extensions: [glScript],
              captureAllGestures: true,
              option: options,
            ),
            width: Get.width,
            height: Get.height - 200,
          ),
          Container(
            height: 20,
            color: Colors.blue,
          ),
          Expanded(
            child: Container(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Функция: ${f.function}'),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Минимальный: $min'),
                    SizedBox(
                      width: 10,
                    ),
                    Text('МинАлгоритма: $min'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String graph() {
  min = null;
  List<List<double>> z = [];
  for (double i = -1; i <= 1; i += 0.05) {
    for (double j = -1; j <= 1; j += 0.05) {
      double res = f.calc(x: j, y: i);
      if (min == null) {
        min = res;
      } else if (min! > res) {
        min = res;
      }
      z.add([j, i, res]);
    }
  }
  return z.toString();
}

String generateOptions(String value) {
  return '''
{
  tooltip: {},
  backgroundColor: '#fff',
  visualMap: {
    show: false,
    dimension: 2,
    min: -1,
    max: 1,
    inRange: {
      color: [
        '#313695',
        '#4575b4',
        '#74add1',
        '#abd9e9',
        '#e0f3f8',
        '#ffffbf',
        '#fee090',
        '#fdae61',
        '#f46d43',
        '#d73027',
        '#a50026'
      ]
    }
  },
  xAxis3D: {
    type: 'value'
  },
  yAxis3D: {
    type: 'value'
  },
  zAxis3D: {
    type: 'value'
  },
  grid3D: {
    viewControl: {
      // projection: 'orthographic'
    }
  },
  series: [
    {
      type: 'surface',
      wireframe: {
        // show: false
      },
      data: ${value}
    }
  ]
}
''';
}
