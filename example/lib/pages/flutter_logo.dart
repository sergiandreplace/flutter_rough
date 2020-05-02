import 'package:flutter/material.dart';
import 'package:rough/rough.dart';

class FlutterLogoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rough Flutter logo")),
      body: FlutterLogoCanvas(),
    );
  }
}

class FlutterLogoCanvas extends StatelessWidget {
  final DrawConfig options;

  const FlutterLogoCanvas({Key key, this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: FlutterLogoPainter(),
    );
  }
}

class FlutterLogoPainter extends CustomPainter {
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

  @override
  void paint(Canvas canvas, Size size) {
    DrawConfig config = DrawConfig.build(
      roughness: 1,
      maxRandomnessOffset: 1.2,
      bowing: 8,
      curveFitting: 5,
      curveStepCount: 5,
      curveTightness: 1,
      seed: 3,
    );

    FillerConfig fillerConfig = FillerConfig(
      hachureAngle: -50,
      dashGap: 3,
      dashOffset: 2,
      drawConfig: DrawConfig.build(maxRandomnessOffset: 1, bowing: 0, curveFitting: 0.1, roughness: 0.8),
      fillWeight: 10,
      hachureGap: 10,
      zigzagOffset: 1,
    );

    Generator gen = Generator(config, HatchFiller(fillerConfig));
    canvas.scale(2);
    canvas.translate(11, 46);
    rough.draw(canvas, gen.polygon([PointD(37, 128), PointD(9, 101), PointD(100, 10), PointD(156, 10)]), stroke, fillPaint);
    canvas.translate(-4, -4);
    rough.draw(canvas, gen.polygon([PointD(156, 94), PointD(100, 94), PointD(50, 141), PointD(79, 170)]), stroke, fillPaint);
    canvas.translate(6, 6);
    rough.draw(canvas, gen.polygon([PointD(79, 170), PointD(100, 191), PointD(156, 191), PointD(107, 142)]), stroke, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
