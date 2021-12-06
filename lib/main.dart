import 'dart:math';
import 'package:bfo/custom_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:eticon_extension/eticon_extension.dart';

import 'bacteria.dart';
import 'glScript.dart' show glScript;

late cFunction f;

double globalX = 0;
double globalY = 0;
double? min = null;

late Bacteria best;

void main() {
  ELogSettings.disableLogs(true);
  f = cFunction(function: 'x^2+y^2');// функция сферы
  // f = cFunction(function: '20+(x^2-10*cos(2*pi*x))+(y^2-10*cos(2*pi*y))');// функция Растринга
  // f = cFunction(
  //     function:
  //         '-20*e^(-0.2*sqrt(0.5*(x^2)+(y^2)))-e^(0.5*(cos(2*pi*x)+cos(2*pi*y)))+20+2.718281828459045'); //Функция Экли
  BacteriaCalculate bc = BacteriaCalculate();
  best = bc.Start();
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
          SizedBox(height: 20,),
          Text('Функция: ${f.function}'),
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              height: 100,
              width: 800,
              child: Table(
                border: TableBorder.all(color: Colors.black, width: 1),
                children: [
                  // TableRow(),
                  TableRow(
                    children: [
                      Container(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('X'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Y'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('f(X, Y)'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Мин'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(minX.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(minY.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(min.toString()),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Бактерии'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(best.vector[0].toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(best.vector[1].toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(best.cost.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // child: Center(
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Text('Функция: ${f.function}'),
            //       SizedBox(
            //         width: 10,
            //       ),
            //     ],
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}

double? minX;
double? minY;

String graph() {
  min = null;
  List<List<double>> z = [];
  for (double i = -5; i <= 5; i += 0.05) {
    for (double j = -5; j <= 5; j += 0.05) {
      double res = f.calc(x: j, y: i);
      if (min == null) {
        min = res;
        minX = j;
        minY = i;
      } else if (min! > res) {
        min = res;
        minX = j;
        minY = i;
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
    min: 0,
    max: 80,
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
