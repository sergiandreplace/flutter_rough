import 'package:flutter/material.dart';

import 'core.dart';

class Rough {
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
    final List<OpSet> opSets = drawable.sets ?? [];
    opSets.forEach((drawing) {
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
}
