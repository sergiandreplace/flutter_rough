import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'core.dart';
import 'filler.dart';
import 'generator.dart';

class RoughCanvas extends StatelessWidget {
  final DrawConfig options;

  const RoughCanvas({Key key, this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: RoughPainter(),
    );
  }
}

class RoughPainter extends CustomPainter {
  _drawToContext(Canvas canvas, OpSet drawing, Paint paint) {
    Path path = Path();
    drawing.ops.forEach((item) {
      final data = item.data;
      switch (item.op) {
        case OpType.move:
          path.moveTo(data[0].x, data[0].y);
          break;
        case OpType.curveTo:
          path.cubicTo(data[0].x, data[0].y, data[1].x, data[1].y, data[2].x, data[2].y);
          break;
        case OpType.lineTo:
          path.lineTo(data[0].x, data[0].y);
          break;
      }
    });
    canvas.drawPath(path, paint);
  }

  draw(Canvas canvas, Drawable drawable, Paint pathPaint, Paint fillPaint) {
    final sets = drawable.sets ?? [];
    sets.forEach((drawing) {
      switch (drawing.type) {
        case OpSetType.path:
          _drawToContext(canvas, drawing, pathPaint);
          break;
        case OpSetType.fillPath:
          _drawToContext(canvas, drawing, fillPaint);
          break;
        case OpSetType.fillSketch:
          _drawToContext(canvas, drawing, fillPaint);
          break;
      }
    });
  }

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
    Random r = Random();

    DrawConfig config = DrawConfig(
      roughness: 1,
      maxRandomnessOffset: 1.2,
      bowing: 8,
      curveFitting: 5,
      curveStepCount: 5,
      curveTightness: 1,
      seed: 3,
    );

    FillerConfig fillerConfig = FillerConfig(
      hachureAngle: -40,
      dashGap: 5,
      dashOffset: 3,
      drawConfig: config.copyWith(maxRandomnessOffset: 10, bowing: 0, curveFitting: 0.1, roughness: 0.8),
      fillWeight: 10,
      hachureGap: 2.5,
      zigzagOffset: 1,
    );

    Generator gen = Generator(config, ZigZagFiller(fillerConfig));
    canvas.scale(2);
    canvas.translate(11, 46);
    draw(canvas, gen.polygon([PointD(37.7, 128.9), PointD(9.8, 101), PointD(100.4, 10.4), PointD(156.2, 10.4)]), stroke, fillPaint);
    canvas.translate(-4, -4);

    draw(canvas, gen.polygon([PointD(156.2, 94), PointD(100.4, 94), PointD(50.7, 141.9), PointD(79.5, 170.7)]), stroke, fillPaint);
    canvas.translate(6, 6);
    draw(canvas, gen.polygon([PointD(79.5, 170.7), PointD(100.4, 191.6), PointD(156.2, 191.6), PointD(107.4, 142.8)]), stroke, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
