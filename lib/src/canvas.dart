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
  var colors = <Color>[
    Colors.black,
    Colors.black54,
    Colors.black87,
  ];

  Paint stroke = Paint()
    ..strokeWidth = 1
    ..isAntiAlias = true
    ..color = Colors.black
    ..strokeCap = StrokeCap.square
    ..style = PaintingStyle.stroke;

  Paint debug = Paint()
    ..strokeWidth = 1
    ..isAntiAlias = true
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

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
    pathPaint.color = Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(Random().nextDouble());
    fillPaint.color = Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(Random().nextDouble());
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

  @override
  void paint(Canvas canvas, Size size) {
    Random r = Random();

    DrawConfig config = DrawConfig(
      roughness: r.nextDouble() * 3,
      maxRandomnessOffset: 2,
      bowing: r.nextDouble() * 20,
      curveFitting: r.nextDouble() * 1,
      curveStepCount: r.nextDouble() * 5,
      curveTightness: r.nextDouble() + 0.5,
      seed: 3,
    );

    double s = 300;
    Generator squareGenerator = Generator(config, ZigZagFiller());

    draw(canvas, squareGenerator.rectangle((size.width - s) / 2, (size.height - s) / 2, s, s), stroke, debug);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
