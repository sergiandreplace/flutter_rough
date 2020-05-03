import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

import '../interactive_canvas.dart';

class FlutterLogoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Interactive Flutter Logo")),
      body: InteractiveBody(
        painterbuilder: (drawConfig) => FlutterLogoPainter(drawConfig),
        properties: <DiscreteProperty>[
          DiscreteProperty(name: "seed", label: "Seed", min: 0, max: 50, steps: 50),
          DiscreteProperty(name: "roughness", label: "Rougness", min: 0, max: 2, steps: 50),
          DiscreteProperty(name: "curveFitting", label: "curveFitting", min: 0, max: 2, steps: 50),
          DiscreteProperty(name: "curveTightness", label: "curveTightness", min: 0, max: 1, steps: 100),
          DiscreteProperty(name: "curveStepCount", label: "curveStepCount", min: 1, max: 11, steps: 100),
        ],
      ),
    );
  }
}

class FlutterLogoPainter extends InteractivePainter {
  final Rough rough = Rough();

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

  FlutterLogoPainter(DrawConfig drawConfig) : super(drawConfig);

  @override
  void paintRough(canvas, size) {
    FillerConfig fillerConfig = FillerConfig(
      hachureAngle: -50,
      dashGap: 3,
      dashOffset: 2,
      drawConfig: drawConfig.copyWith(maxRandomnessOffset: 1, bowing: 0, curveFitting: 0.1, roughness: 0.8),
      fillWeight: 10,
      hachureGap: 10,
      zigzagOffset: 1,
    );

    Generator gen = Generator(drawConfig, ZigZagFiller(fillerConfig));
    canvas.scale(1);
    canvas.translate(11, 46);
    rough.draw(canvas, gen.polygon([PointD(37, 128), PointD(9, 101), PointD(100, 10), PointD(156, 10)]), stroke, fillPaint);
    canvas.translate(-4, -4);
    rough.draw(canvas, gen.polygon([PointD(156, 94), PointD(100, 94), PointD(50, 141), PointD(79, 170)]), stroke, fillPaint);
    canvas.translate(6, 6);
    rough.draw(canvas, gen.polygon([PointD(79, 170), PointD(100, 191), PointD(156, 191), PointD(107, 142)]), stroke, fillPaint);
  }
}
