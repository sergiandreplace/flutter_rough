import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import '../interactive_canvas.dart';

class RectangleExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive rectangle demo')),
      body: InteractiveBody(
        example: RectangleExample(),
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

class RectangleExample extends InteractiveExample {
  final Paint pathPaint = Paint()
    ..color = Colors.lightGreen.withOpacity(0.8)
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.square
    ..strokeWidth = 5;
  final Paint fillPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 1;

  @override
  void paintRough(Canvas canvas, Size size, DrawConfig drawConfig) {
    Generator generator = Generator(drawConfig, NoFiller(FillerConfig.build().copyWith(drawConfig: drawConfig)));

    Drawable figure = generator.rectangle(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6);
    canvas.drawRough(figure, pathPaint, fillPaint);
  }
}
