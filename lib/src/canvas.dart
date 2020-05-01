import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'core.dart';
import 'generator.dart';

class RoughCanvas extends StatelessWidget {
  final Options options;

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
  Generator generator = Generator();
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

  _drawToContext(Canvas canvas, OpSet drawing) {
    Path path = Path();
    drawing.ops.forEach((item) {
      final data = item.data;
      switch (item.op) {
        case OpType.move:
          //debugPrint('move $data');
          path.moveTo(data[0], data[1]);
          break;
        case OpType.bCurveTo:
          //debugPrint('bCurveTo $data');
          path.cubicTo(data[0], data[1], data[2], data[3], data[4], data[5]);
          break;
        case OpType.lineTo:
          //debugPrint('lineTo $data');
          path.lineTo(data[0], data[1]);
          break;
      }
    });
    canvas.drawPath(path, stroke);
  }

  draw(Canvas canvas, Drawable drawable) {
    final sets = drawable.sets ?? [];
    stroke.strokeWidth = drawable.options.strokeWidth;
    stroke.color = drawable.options.stroke;
    sets.forEach((drawing) {
      switch (drawing.type) {
        case OpSetType.path:
          _drawToContext(canvas, drawing);
          break;
        case OpSetType.fillPath:
          // TODO: Handle this case.
          break;
        case OpSetType.fillSketch:
          _drawToContext(canvas, drawing);
          break;
      }
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    Random r = Random();
    int max = 30;
    for (int i = 0; i < 60; i++) {
      double x = r.nextDouble() * (size.width);
      double y = r.nextDouble() * (size.height);
      double w = r.nextDouble() * 30 + 50;
      double h = r.nextDouble() * 30 + 50;
      Options o = Options(
        roughness: r.nextDouble() * 3,
        maxRandomnessOffset: 2,
        bowing: r.nextDouble() * 20,
        curveFitting: r.nextDouble() * 1,
        curveStepCount: r.nextDouble() * 5,
        curveTightness: r.nextDouble() * 5,
        stroke: Colors.primaries[r.nextInt(Colors.primaries.length)].withOpacity(r.nextDouble()),
        strokeWidth: r.nextDouble() * 0.5 + 1,
        hachureAngle: r.nextDouble() * 180,
        hachureGap: r.nextDouble() * 10 + 8,
        dashGap: 10,
        seed: 3,
      );
      if (r.nextInt(2) == 1) {
        draw(canvas, generator.circle(x, y, w * 2, options: o));
      } else {
        draw(canvas, generator.rectangle(x - w / 2, y - h / 2, w, h, options: o));
      }
    }
//    double s = 300;
//    draw(canvas, generator.rectangle((size.width - s) / 2, (size.height - s) / 2, s, s));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
