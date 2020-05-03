import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import '../interactive_canvas.dart';

class InteractiveRectanglePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Interactive rectangle demo")),
      body: InteractiveBody(
        painterbuilder: (drawConfig) => Rectangle(drawConfig),
        properties: <DiscreteProperty>[
          DiscreteProperty(name: "seed", label: "Seed", min: 0, max: 50, steps: 50),
          DiscreteProperty(name: "roughness", label: "Roughness", min: 0, max: 5, steps: 50),
          DiscreteProperty(name: "bowing", label: "Bowing", min: 0, max: 10, steps: 50),
          DiscreteProperty(name: "maxRandomnessOffset", label: "maxRandomnessOffset", min: 0, max: 10, steps: 50),
        ],
      ),
    );
  }
}

class Rectangle extends InteractivePainter {
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

  Rectangle(DrawConfig drawConfig) : super(drawConfig);

  @override
  void paintRough(Canvas canvas, Size size) {
    Generator generator = Generator(drawConfig, NoFiller(FillerConfig().copyWith(drawConfig: drawConfig)));

    Drawable figure = generator.rectangle(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6);
    Rough().draw(canvas, figure, pathPaint, fillPaint);
  }
}
