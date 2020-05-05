import 'package:flutter/material.dart';

import 'core.dart';
import 'entities.dart';

/// This is the base Rough class for painting
extension Rough on Canvas {
  void _drawToContext(OpSet drawing, Paint paint) {
    Path path = Path();
    for (Op op in drawing.ops) {
      final data = op.data;
      switch (op.op) {
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
    }
    drawPath(path, paint);
  }

  /// Draws a rough Drawable
  ///
  ///
  void drawRough(Drawable drawable, Paint pathPaint, Paint fillPaint) {
    drawable.sets ?? []
      ..forEach((drawing) {
        switch (drawing.type) {
          case OpSetType.path:
            _drawToContext(drawing, pathPaint);
            break;
          case OpSetType.fillPath:
            _drawToContext(drawing, fillPaint);
            break;
          case OpSetType.fillSketch:
            _drawToContext(drawing, fillPaint);
            break;
        }
      });
  }
}
