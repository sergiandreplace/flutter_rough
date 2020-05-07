import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import '../interactive_canvas.dart';

class FlutterLogoExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Flutter Logo')),
      body: InteractiveBody(
        example: FlutterLogoExample(),
        properties: <DiscreteProperty>[
          DiscreteProperty(name: 'seed', label: 'Seed', min: 0, max: 50, steps: 50),
          DiscreteProperty(name: 'roughness', label: 'Roughness', min: 0, max: 5, steps: 50),
          DiscreteProperty(name: 'bowing', label: 'Bowing', min: 0, max: 10, steps: 50),
          DiscreteProperty(name: 'maxRandomnessOffset', label: 'maxRandomnessOffset', min: 0, max: 10, steps: 50),
        ],
      ),
    );
  }
}

class FlutterLogoExample extends InteractiveExample {
  Paint stroke = Paint()
    ..strokeWidth = 2
    ..isAntiAlias = true
    ..color = Colors.blueAccent
    ..strokeCap = StrokeCap.square
    ..style = PaintingStyle.stroke;

  Paint fillPaint = Paint()
    ..strokeWidth = 1
    ..isAntiAlias = true
    ..color = Colors.lightBlueAccent
    ..style = PaintingStyle.stroke;

  @override
  void paintRough(canvas, size, drawConfig, Filler filler) {
    Generator gen = Generator(drawConfig, filler);
    double logoWidth = 165;
    double logoHeight = 201;
    double widthScale = (size.width) / (logoWidth);
    double heightScale = (size.height) / (logoHeight);
    double scale = min(widthScale, heightScale);
    double translateX = (size.width - logoWidth * scale) / 2;
    double translateY = (size.height - logoHeight * scale) / 2;

    canvas
      ..translate(translateX, translateY)
      ..scale(scale)
      ..drawRough(gen.polygon([PointD(37, 128), PointD(9, 101), PointD(100, 10), PointD(156, 10)]), stroke, fillPaint)
      ..translate(-4, -4)
      ..drawRough(gen.polygon([PointD(156, 94), PointD(100, 94), PointD(50, 141), PointD(79, 170)]), stroke, fillPaint)
      ..translate(6, 6)
      ..drawRough(gen.polygon([PointD(79, 170), PointD(100, 191), PointD(156, 191), PointD(107, 142)]), stroke, fillPaint);
  }
}
